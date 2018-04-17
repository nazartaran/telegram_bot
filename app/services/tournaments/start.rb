require 'thread'

module Tournaments
  class Start
    ROUND_TIME_IN_SECONDS = 60
    WINNERS_COUNT = 1
    Response = Struct.new(:response_text)

    def self.call(*args)
      new(*args).call
    end

    def initialize(bot, time_until_start)
      @bot = bot
      @tournament = Tournament.create!(name: SecureRandom.hex, ongoing: true)
      @time_until_start = time_until_start.to_i.seconds
    end

    def call
      announce_start
      sleep(time_until_start)

      Thread.new do
        tournament.start

        until tournament.has_winner?
          time = Time.now

          round_question = question(tournament.round)
          ask_question(round_question.body)

          sleep(time + ROUND_TIME_IN_SECONDS - Time.now)
          tournament.next_round

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
      @competitors ||= User.competitors
    end

    def question(round)
      Question.for_round(round)
    end

    def ask_question(question)
      competitors.each do |competitor|
        bot.send_message(chat_id: competitor.chat_id, text: question, parse_mode: 'Markdown')
      end
    end

    def announce_start
      players = tournament.current_competitors.map(&:full_name).join(', ')
      tournament.current_competitors.each do |competitor|
        bot.send_message(chat_id: competitor.chat_id, text: I18n.t('tournament.announce_start', time: time_until_start,
                                                                                                players: players),
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

      GoogleAdapter::Spreadsheets::InsertTournamentWinner.call(winner.full_name)
      message = winner ? I18n.t('tournament.announce_winner', winner: winner.full_name) : I18n.t('tournament.no_winner')
      competitors.each do |competitor|
        bot.send_message(chat_id: competitor.chat_id, text: message, parse_mode: 'Markdown')
      end
    end
  end
end
