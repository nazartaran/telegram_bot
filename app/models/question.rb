class Question
  include Mongoid::Document

  field :body, type: String
  field :answers, type: Array
  field :outdated, type: Boolean, default: false
  field :round, type: Integer

  validates :body, :answers, presence: true
  validates :body, uniqueness: { scope: :answers }

  def self.for_round(round)
    find_by(outdated: false, round: round)
  end
end
