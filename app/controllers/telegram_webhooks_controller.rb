class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  use_session!

  def start(*)
    respond_with :message, text: t('.hi'), reply_markup: get_markup('/za_10', '/stop')
  end

  def stop(*)
    session.delete(:score)
    clear_questions_in_progress

    respond_with :message, text: t('.bye'), reply_markup: get_markup('/start')
  end

  def skip(*)
    clear_questions_in_progress

    respond_with :message, text: t('.no_active_questions'), reply_markup: get_markup('/za_10')
  end

  def clear_my_score(*)
    session.delete(:score)

    respond_with :message, text: "Ваш поточний рахунок: #{session[:score].to_i}", 
                           reply_markup: get_markup('/za_10')
  end

  def clear_questions(*)
    session.delete(:played_question_ids)

    respond_with :message, text: "Тепер у вас зіграно #{session[:played_question_ids].to_i} питань!", 
                           reply_markup: get_markup('/za_10')
  end

  def show_score(*)
    respond_with :message, text: "Ваш поточний рахунок: #{session[:score].to_i}", 
                           reply_markup: get_markup('/za_10', '/clear_my_score', '/stop')
  end

  def message(message)
    question_context = first_question_in_progress

    if question_context
      if session[question_context][:answer].include?(message['text'].mb_chars.downcase.to_s)
        session[question_context].delete(:answer)
        questions_in_progress(question_context, false)
        session[:score] += 10

        response_text = "10 очок на барабані! Ваш поточний рахунок: #{session[:score]}"
        markup = get_markup('/za_10')
      else
        response_text = t('.ongoing_question.failure', action_name: question_context)
        markup = get_markup('/skip')
      end
    elsif Tournament.ongoing && current_user.competes_in_tournament
      result = Tournaments::ResponseParser.parse(message['text'].mb_chars.downcase.to_s, current_user)
      response_text = result.message
      markup = nil
    else
      response_text = message['text']
      markup = nil
    end

    respond_with :message, text: response_text, reply_markup: markup
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

  def za_10(*)
    init_current_action
    question = maybe_question

    if question
      session[action_name][:answer] = question[:answer]
      session[:played_question_ids] << question[:id]

      save_context :za_10
      respond_with :message, text: question[:question]
    else
      clear_questions_in_progress
      respond_with :message, text: t('.no_more_questions'), reply_markup: get_markup('/clear_questions', '/stop', '/show_score')
    end
  end

  context_handler :za_10 do |message|
    if session[context][:answer].include?(message.mb_chars.downcase.to_s)
      session[context].delete(:answer)
      questions_in_progress(context, false)
      clear_questions_in_progress
      session[:score] += 10

      response_text = "10 очок на барабані! Ваш поточний рахунок: #{session[:score]}"
      markup = get_markup('/za_10', '/clear_my_score')
    else
      response_text = 'Ноуп.'
      markup = get_markup('/skip')
    end

    respond_with :message, text: response_text, reply_markup: markup
  end

  private

  def questions
    [
      { question: "Тема: Довкола спорту. Питання: На соціальній рекламі поруч зображені баскетболіст з мячем у руці та людина із сигаретою. Підпис закликає обох героїв РОБИТИ ЦЕ.",
        answer: ['кидати', 'бросать', 'кидать', 'кинути'], id: 5 },
      { question: "Тема: Щити. Питання: ЦЕЙ ЩИТ дав назву щотижневому американському журналу, присвяченому музичній індустрії. До речі, автор питання швидко і недорого напише потрібну кількість тем 'своєї гри' для чемпіонату вашого міста або вузу.",
        answer: ['бігборд', 'біг-борд', 'білборд', 'билборд', 'рекламний щит', 'рекламный щит'], id: 6 },
      { question: "Тема: Фінансова тема. Питання: Жадібний Біллі не бажав платити ЇХ ні за цукерки, ні за астри.",
        answer: ['піастри', 'пьястри', 'пиастры'], id: 7 },
      { question: "Тема: Музика та музиканти. Питання: Згідно з дослідженнями вчених, в більшості своїй ВОНИ глухуваті на ліве вухо.",
        answer: ['скрипалі', 'скрипачі', 'скрипаль', 'скрипач', 'скрипачь'], id: 8 },
      { question: "Тема: Божевільна тема. Питання: Батько Карла VI Божевільного носив ЦЕ ПРІЗВИСЬКО, не дарма ж кажуть, що природа на дітях відпочиває.",
        answer: ['мудрий', 'розумний', 'мудрый'], id: 9 },
      { question: "Тема: Закордонний шоубіз. Питання: Журнал 'Forbes' у 2012 році назвав ЙОГО третім серед найвпливовіших знаменитостей у світі, що не завадило пресі в його рідній Канаді відчитати ЙОГО як хлопчиська за неналежний вигляд на візиті до прем'єр-міністра.",
        answer: ['бібер', 'джастін бібер', 'бібєр', 'джастін бібєр', 'bieber', 'justin bieber'], id: 10 },
      { question: "Тема: Сиджу за ґратами. Питання: На ЦЬОМУ ОСТРОВІ немає жодної колонії пеліканів, та й колонії для особливо небезпечних злочинців вже давно немає: зараз вона перетворилася в музей.",
        answer: ['алькатрас', 'алкатрас', 'alcatraz'], id: 11 },
      { question: "Тема: Вигадані землі. Питання: Відомий письменник придумав ЦЕЙ вигаданий КОНТИНЕНТ, буквально переклавши назву населеного людьми міфічного світу, що знаходиться посередині між небесами і пеклом.",
        answer: ["середзем'я", 'средиземье', 'middle-earth', 'середземя'], id: 12 },
      { question: "Тема: Вигадані землі. Питання: Борис Заходер переклав ЦЮ НАЗВУ як 'Гдетотам'.",
        answer: ['неверленд', 'neverland'], id: 13 },
      { question: "Тема: Погана тема. Питання: Погано спроектована, слабо структурована, заплутана і важка для розуміння програма називається терміном, що містить ЦЕЙ ПРОДУКТ ХАРЧУВАННЯ.",
        answer: ['спагеті', 'спагетті', 'spagetti', 'spaghetti', 'spaghetti code', 'spagetti code', 'спагеті код', 'спагетти код', 'спагетті код'], id: 14 }
    ]
  end

  def maybe_question
    if session[:played_question_ids].size < questions.size
      filtered_questions = questions.dup.delete_if { |question_hash| question_hash[:id].in?(session[:played_question_ids]) }
      filtered_questions.sample
    end
  end

  def init_current_action
    session[action_name] = session[action_name] || {}.with_indifferent_access
    session[:played_question_ids] = session[:played_question_ids] || []
    session[:score] = session[:score] || 0
    questions_in_progress(action_name, true)
  end

  def questions_in_progress(action, bool)
    session[:questions_in_progress] = session[:questions_in_progress] || {}.with_indifferent_access
    session[:questions_in_progress][action] = bool
  end

  def first_question_in_progress
    return unless session[:questions_in_progress]

    question_hash = session[:questions_in_progress].find { |action, state| state }
    question_hash&.first
  end

  def clear_questions_in_progress
    return unless session[:questions_in_progress]

    session[:questions_in_progress].each do |action, bool|
      session[:questions_in_progress][action] = false
    end
  end

  def get_markup(*buttons)
    Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: buttons.each_slice(1), one_time_keyboard: true).to_h
  end

  def current_user
    @current_user ||= User.resolve_user(payload['from'].merge!('chat_id' => payload['chat']['id']))
  end
end
