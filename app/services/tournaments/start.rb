require 'thread'

module Tournaments
  class Start
    ROUND_TIME_IN_SECONDS = 60
    WINNERS_COUNT = 1
    Response = Struct.new(:response_text)
    NO_ONE = 'NoOne'

    def self.call(*args)
      new(*args).call
    end

    def initialize(bot, time_until_start)
      @bot = bot
      @tournament = Tournament.create!(name: SecureRandom.hex, ongoing: true)
      GoogleAdapter::Spreadsheets::InsertUsers.call
      @time_until_start = time_until_start.to_i.seconds
    end

    def call
      announce_players

      Thread.new do
        sleep(time_until_start)

        tournament.start

        until tournament.has_winner? || tournament.no_answers_at_all?
          time = Time.now

          round_question = question(tournament.round)
          ask_question(round_question.body)

          sleep(time + ROUND_TIME_IN_SECONDS - Time.now)
          tournament.next_round
          round_question.update(outdated: true)

          tournament.refresh_correct_counter
        end

        finish_tournament
      end
    end

    private

    attr_reader :bot, :tournament, :time_until_start

    def result(text:)
      Response.new(response_text: text)
    end

    def competitors
      @competitors ||= NotifyCompetitors.new
    end

    def question(round)
      Question.for_round(round)
    end

    def ask_question(question)
      # "\"Lorem\" is just a \"word\"" => "«Lorem» is just a «word»"
      escaped_question = question.gsub(/(\")([^\"]+?)(\")/, '«\2»')

      competitors.each do |competitor|
        bot.send_message(chat_id: competitor.chat_id, text: escaped_question)
      end
    end

    def announce_players
      player_counts = tournament.current_competitors.count
      competitors.each do |competitor|
        bot.send_message(chat_id: competitor.chat_id, text: I18n.t('tournament.announce_start',
                                                                   time: time_until_start,
                                                                   player_counts: player_counts),
                                                      parse_mode: 'Markdown')
      end
    end

    def finish_tournament
      tournament.finish
      announce_winner
      User.update_all(competes_in_tournament: false, round: nil)
      CorrectUser.delete_all
    end

    def announce_winner
      winner = CorrectUser.winner(tournament.previous_round)

      GoogleAdapter::Spreadsheets::InsertTournamentWinner.call(winner&.full_name || NO_ONE)
      message = winner ? I18n.t('tournament.announce_winner', winner: winner.full_name) : I18n.t('tournament.no_winner')
      competitors.each do |competitor|
        bot.send_message(chat_id: competitor.chat_id, text: message, parse_mode: 'Markdown')
      end
    end
  end
end
