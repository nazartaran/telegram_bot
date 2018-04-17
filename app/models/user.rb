class User
  include Mongoid::Document

  field :first_name, type: String
  field :last_name, type: String
  field :username, type: String
  field :language_code, type: String
  field :uid, type: Integer
  field :chat_id, type: Integer
  field :round, type: Integer
  field :competes_in_tournament, type: Boolean, default: 0
  field :is_bot, type: Boolean, default: 0
  field :is_admin, type: Boolean, default: 0

  index({ uid: 1 }, { unique: true, name: 'uid_index' })

  validates_uniqueness_of :uid

  scope :competitors, -> { where(competes_in_tournament: true) }

  def self.make_admin_by_name(first_name, last_name)
    find_by(first_name: first_name, last_name: last_name)&.update(is_admin: true)
  end

  def self.resolve_user(user_params)
    user = find_by(uid: user_params['id'])

    user.update(user_params.except('id')) if user

    return user if user

    create(first_name: user_params['first_name'],
           last_name: user_params['last_name'],
           username: user_params['username'],
           uid: user_params['id'],
           chat_id: user_params['chat_id'])
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
