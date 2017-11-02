class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  use_session!

  def message(message)
    respond_with :message, text:  message['text'], reply_markup: nil
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
