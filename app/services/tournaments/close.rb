module Tournaments
  module Close
    def self.now
      User.update_all(competes_in_tournament: false)
      CorrectUser.delete_all
      Tournament.delete_all
      RegistrationStatus.instance.update(on: false)
    end
  end
end
