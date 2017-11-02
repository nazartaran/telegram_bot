class CorrectUser
  include Mongoid::Document

  field :uid, type: Integer
  field :round, type: Integer

  scope :for_round, ->(round) { where(round: round) }

  def self.winner(final_round)
    winner_uid = resolve_winner(final_round)
    User.find_by(uid: winner_uid)
  end

  private

  def self.resolve_winner(final_round)
    winner = find_by(round: final_round) || for_round(final_round - 1).desc('_id').first
    winner&.uid
  end
end
