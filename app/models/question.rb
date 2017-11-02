class Question
  include Mongoid::Document

  field :body, type: String
  field :answers, type: Array
  field :for_tournament, type: Boolean, default: false
  field :round, type: Integer

  validates :body, :answers, presence: true

  def self.for_round(round)
    find_by(for_tournament: true, round: round)
  end
end
