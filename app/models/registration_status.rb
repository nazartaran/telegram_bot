class RegistrationStatus
  include Mongoid::Document

  field :on, type: Boolean, default: false

  def self.instance
    RegistrationStatus.first || RegistrationStatus.create
  end
end
