class Question
  include Mongoid::Document

  field :body, type: String
  field :answers, type: Array
  field :outdated, type: Boolean, default: false
  field :round, type: Integer

  validates :body, :answers, presence: true
  validates :body, uniqueness: { scope: :answers }

  def self.last_played_set
    1.upto(5).map { |n| for_old_round(n) }.compact
  end

  def self.for_old_round(round)
    find_by(outdated: true, round: round)
  end

  def self.for_round(round)
    find_by(outdated: false, round: round)
  end
end
