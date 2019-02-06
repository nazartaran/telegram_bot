module Tournaments
  class ResponseParser
    PERMISSIBLE_COINCIDENCE_PERCENTAGE = 80
    Result = Struct.new(:message, :correct_answer?, :continue?)

    def self.parse(*args)
      new(*args).parse
    end

    def initialize(answer, user)
      @answer = answer
      @user = user
      @ongoing_tournament = Tournament.ongoing
    end

    def parse
      if previously_lost?
        non_scoring_parser
      else
        scoring_parser
      end
    end

    private

    attr_reader :answer, :user, :ongoing_tournament

    def non_scoring_parser
      if correct_answer?
        result(message: I18n.t('tournament.correct_answer.non_scoring'), correct_answer: true)
      else
        result(message: I18n.t('tournament.incorrect_answer'))
      end
    end

    def scoring_parser
      if user.is_magister?
        result(message: I18n.t('tournament.magister_answer'))
      elsif user_already_answered?
        result(message: I18n.t('tournament.already_answered'))
      elsif correct_answer? && answer_in_time?
        mark_user_as_correct
        GoogleAdapter::Spreadsheets::InsertRoundWinner.call(user.full_name, Tournament.ongoing, correct_users_count)

        result(message: I18n.t('tournament.correct_answer.continue'), correct_answer: true, continue: true)
      elsif correct_answer?
        result(message: I18n.t('tournament.correct_answer.too_late'), correct_answer: true)
      else
        result(message: I18n.t('tournament.incorrect_answer'))
      end
    end

    def result(message:, correct_answer: false, continue: false)
      Result.new(message, correct_answer, continue)
    end

    def user_already_answered?
      CorrectUser.find_by(uid: user.uid, round: ongoing_tournament.round)
    end

    def previously_lost?
      return false if ongoing_tournament.first_round?

      CorrectUser.find_by(uid: user.uid, round: ongoing_tournament.previous_round).nil?
    end

    def correct_answer?
      round_answers.any? { |round_answer| round_answer.similar(answer) >= PERMISSIBLE_COINCIDENCE_PERCENTAGE }
    end

    def round_answers
      @round_answers ||= Question.for_round(ongoing_tournament.round).answers
    end

    def answer_in_time?
      correct_users_count < ongoing_tournament.max_correct_users_count
    end

    def mark_user_as_correct
      CorrectUser.create!(uid: user.uid, round: ongoing_tournament.round)
    end

    def correct_users_count
      CorrectUser.for_round(ongoing_tournament.round).count
    end
  end
end
