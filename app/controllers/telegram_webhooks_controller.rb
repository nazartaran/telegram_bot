class TelegramWebhooksController < Telegram::Bot::UpdatesController
  REGISTER = 'register'.freeze

  include Telegram::Bot::UpdatesController::MessageContext
  use_session!

  def start(*)
    current_user
  end

  def message(message)
    if document?(message)
      proceed_csv(message)
    elsif photo?(message)
      proceed_photo(message)
    elsif sticker?(message)
      process_sticker(message)
    elsif message['text'].present?
      if Tournament.ongoing && current_user.competes_in_tournament
        result = Tournaments::ResponseParser.parse(message['text'].mb_chars.downcase.to_s, current_user)
        response_text = result.message
      else
        response_text = message['text']
      end

      respond_with :message, text: response_text, reply_markup: nil
    end
  end

  def add_admin!(pwd = nil, first_name, last_name)
    return unless current_user_is_admin? || pwd == Rails.application.secrets[:bot_publish_password]

    if User.make_admin_by_name(first_name, last_name)
      respond_with :message, text: t('.added')
    else
      respond_with :message, text: t('.bad_data')
    end
  end

  def add_magister!(pwd = nil, first_name, last_name)
    return unless current_user_is_admin? || pwd == Rails.application.secrets[:bot_publish_password]

    if User.make_magister_by_name(first_name, last_name)
      respond_with :message, text: t('.added')
    else
      respond_with :message, text: t('.bad_data')
    end
  end

  def admin!
    return unless current_user_is_admin?

    respond_with :message, text: t('.hi_admin', name: current_user.full_name), reply_markup: {
      inline_keyboard: [
        [{ text: t('.notify'), callback_data: 'notify' }],
        [{ text: t('.announce'), callback_data: 'init_tournament' }],
        [{ text: t('.competitors_count'), callback_data: 'competitors_count' }],
        [{ text: t('.start'), callback_data: 'start_tournament' }],
        [{ text: t('.close'), callback_data: 'close_tournament' }],
        [{ text: t('.add'), callback_data: 'add_questions' }],
        [{ text: t('.up_to_date_question'), callback_data: 'up_to_date_question' }]
      ]
    }
  end

  def callback_query(data, *attrs)
    answer_callback_query nil
    if data == REGISTER
      register_handler(payload['message']['message_id'])
    else
      send(data, *attrs)
    end
  rescue
    respond_with :message, text: t('.try_again')
  end

  private

  # Admin Section
  def init_tournament
    return unless current_user_is_admin?

    RegistrationStatus.instance.update(on: true)

    NotifyAll.new.each do |subscriber|
      bot.send_message(chat_id: subscriber.chat_id, text: t('.initial_tournament'), reply_markup: {
        inline_keyboard: [
          [{ text: t('.register'), callback_data: 'register' }]
        ]
      })
    end
  end

  def competitors_count
    return unless current_user_is_admin?

    respond_with :message, text: User.competitors.count
  end

  def start_tournament(time = 30)
    return unless current_user_is_admin?

    Tournaments::Start.call(bot, time)
  end

  def close_tournament
    return unless current_user_is_admin?

    Tournaments::Close.now

    respond_with :message, text: t('.closed')
  end

  def notify
    return unless current_user_is_admin?

    respond_with :message, text: t('.please_send_a_file')
  end

  def add_questions
    return unless current_user_is_admin?

    respond_with :message, text: t('.attach_csv')
  end

  def up_to_date_question
    return unless current_user_is_admin?

    QuestionManager.up_to_date

    respond_with :message, text: t('.up_to_dated')
  end

  # General Section
  def register_handler(msg_id)
    # delete previous button if it was send no longer then 48 hourse, else - remove button
    begin
      bot.delete_message(chat_id: current_user.chat_id, message_id: msg_id)
    rescue
      bot.edit_message_reply_markup(chat_id: current_user.chat_id, message_id: msg_id, reply_markup: nil) rescue nil
    end
    result = Tournaments::Registration.call(current_user)

    respond_with :message, text: result.response_text, parse_mode: 'Markdown'
  end

  def current_user
    @current_user ||= User.resolve_user(payload['from'].merge!('chat_id' => payload['from']['id']))
  end

  def current_user_is_admin?
    current_user.is_admin?
  end

  # def photo? def document? def sticker?
  %w(photo document sticker).each do |method_name|
    define_method "#{method_name}?" do |msg|
      msg[method_name].present?
    end
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

  def process_sticker(msg)
    respond_with :sticker, sticker: msg['sticker']['file_id']
  end
end
