class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  use_session!

  def message(message)
    if Tournament.ongoing && current_user.competes_in_tournament
      result = Tournaments::ResponseParser.parse(message['text'].mb_chars.downcase.to_s, current_user)
      response_text = result.message
    else
      response_text = message['text']
    end

    respond_with :message, text: response_text, reply_markup: nil
  end

  def register(*)
    result = Tournaments::Registration.call(current_user)

    respond_with :message, text: result.response_text, parse_mode: 'Markdown'
  end

  def start_tournament(tournament_name = nil, time = 30)
    if tournament_name
      Tournaments::Start.call(bot, tournament_name, time)
      response_text = t('.started')
    else
      response_text = t('.enter_name')
    end

    respond_with :message, text: response_text
  end

  def publish_news(pwd, url, link = nil)
    return unless pwd == Rails.application.secrets[:bot_publish_password]

    User.all.each do |subscriber|
      bot.send_photo(chat_id: subscriber.chat_id, photo: url)
      bot.send_message(chat_id: subscriber.chat_id, text: link) if link
    end
  end

  private

  # example usage: get_markup('/za_10', '/clear_my_score', '/stop')
  # code for generating keyboard buttons
  def get_markup(*buttons)
    Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: buttons.each_slice(1), one_time_keyboard: true).to_h
  end

  def current_user
    @current_user ||= User.resolve_user(payload['from'].merge!('chat_id' => payload['chat']['id']))
  end
end
