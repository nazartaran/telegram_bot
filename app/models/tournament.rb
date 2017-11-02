class Tournament
  FIRST_ROUND = 1

  include Mongoid::Document

  field :round, type: Integer, default: 1
  field :correct_users_count, type: Integer, default: 5
  field :name, type: String
  field :ongoing, type: Boolean, default: 1

  def self.ongoing
    find_by(ongoing: true)
  end

  def start
    update_attribute(:round, FIRST_ROUND)
  end

  def next_round
    update_attribute(:round, round + 1)
  end

  def finish
    update_attribute(:ongoing, false)
  end

  def refresh_correct_counter
    return if round == FIRST_ROUND

    update_attribute(:correct_users_count, prev_round_winners.count - 1)
  end

  def previous_round_winners_count
    return correct_users_count if round == FIRST_ROUND

    previous_winners_count = prev_round_winners.count
    previous_winners_count.zero? ? Tournaments::Start::WINNERS_COUNT : previous_winners_count
  end

  def current_competitors
    return User.competitors if round == FIRST_ROUND

    correct_user_ids = CorrectUser.for_round(previous_round).desc('_id').limit(correct_users_count).pluck(:uid)
    User.in(uid: correct_user_ids)
  end

  private

  def prev_round_winners
    CorrectUser.for_round(previous_round)
  end

  def previous_round
    round - 1
  end
end
