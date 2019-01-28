module Tournaments
  class Registration
    Response = Struct.new(:response_text)

    def self.call(*args)
      new(*args).call
    end

    def initialize(user)
      @user = user
    end

    def call
      return result(text: I18n.t('tournament.registration.disabled')) unless RegistrationStatus.instance.on?

      if Tournament.ongoing
        result(text: I18n.t('tournament.registration.tournament_in_progress'))
      elsif user.competes_in_tournament
        result(text: I18n.t('tournament.registration.already_in'))
      else
        user.update_attributes!(competes_in_tournament: true, round: 1)
        result(text: I18n.t('tournament.registration.success'))
      end
    end

    private

    attr_reader :user

    def result(text:)
      Response.new(text)
    end
  end
end
