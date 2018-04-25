class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  use_session!

  def message(message)
    return proceed_csv(message) if document?(message)
    return proceed_photo(message) if photo?(message)
    if Tournament.ongoing && current_user.competes_in_tournament
      result = Tournaments::ResponseParser.parse(message['text'].mb_chars.downcase.to_s, current_user)
      response_text = result.message
    else
      response_text = message['text']
    end

    respond_with :message, text: response_text, reply_markup: nil
  end

  def add_admin(pwd = nil, first_name, last_name)
    return unless current_user_is_admin? || pwd == Rails.application.secrets[:bot_publish_password]

    if User.make_admin_by_name(first_name, last_name)
      respond_with :message, text: t('.added')
    else
      respond_with :message, text: t('.bad_data')
    end
  end

  def admin
    return unless current_user_is_admin?

    respond_with :message, text: t('.hi_admin', name: current_user.full_name), reply_markup: {
      inline_keyboard: [
        [{ text: t('.announce'), callback_data: 'init_tournament' }],
        [{ text: t('.start'), callback_data: 'start_tournament' }],
        [{ text: t('.add'), callback_data: 'add_questions' }],
        [{ text: t('.notify'), callback_data: 'notify' }]
      ]
    }
  end

  def callback_query(data, *attrs)
    answer_callback_query nil
    send(data, *attrs)
  end

  private

  # example usage: get_markup('/za_10', '/clear_my_score', '/stop')
  # code for generating keyboard buttons
  def get_markup(*buttons)
    Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: buttons.each_slice(1), one_time_keyboard: true).to_h
  end

  # Admin Section
  def start_tournament(time = 30)
    return unless current_user_is_admin?

    Tournaments::Start.call(bot, time)

    respond_with :message, text: t('telegram_webhooks.start_tournament.started')
  end

  def init_tournament
    return unless current_user_is_admin?

    NotifyAll.new.each do |subscriber|
      bot.send_message(chat_id: subscriber.chat_id, text: t('.initial_tournament'), reply_markup: {
        inline_keyboard: [
          [{ text: t('.register'), callback_data: 'register' }]
        ]
      })
    end
  end

  def notify
    return unless current_user_is_admin?

    respond_with :message, text: t('.please_send_a_file')
  end

  def add_questions
    return unless current_user_is_admin?

    respond_with :message, text: t('.attach_csv')
  end

  # General Section
  def register(*)
    result = Tournaments::Registration.call(current_user)

    respond_with :message, text: result.response_text, parse_mode: 'Markdown'
  end

  def current_user
    @current_user ||= User.resolve_user(payload['from'].merge!('chat_id' => payload['from']['id']))
  end

  def current_user_is_admin?
    current_user.is_admin?
  end

  def photo?(msg)
    msg['photo'].present?
  end

  def document?(msg)
    msg['document'].present?
  end

  def proceed_photo(msg)
    return unless current_user_is_admin?

    link = msg['caption']

    NotifyAll.new.each do |subscriber|
      bot.send_photo(chat_id: subscriber.chat_id, photo: msg['photo'].sample['file_id'], caption: link)
    end
  end

  def proceed_csv(msg)
    return unless current_user_is_admin?

    path_ending = bot.get_file(msg['document'])['result']['file_path']
    if QuestionsImporter.success?(path_ending)
      respond_with :message, text: t('.success_upload'), parse_mode: 'Markdown'
    else
      respond_with :message, text: t('.bad_upload'), parse_mode: 'Markdown'
    end
  end
end
