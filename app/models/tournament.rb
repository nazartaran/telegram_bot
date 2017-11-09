class Tournament
  FIRST_ROUND = 1
  SECOND_ROUND = 2
  BEGINNING_ROUNDS = [FIRST_ROUND, SECOND_ROUND].freeze
  WINNERS_COUNT = 1

  include Mongoid::Document

  field :round, type: Integer, default: 1
  field :max_correct_users_count, type: Integer, default: 5
  field :name, type: String
  field :ongoing, type: Boolean, default: 1

  def self.ongoing
    find_by(ongoing: true)
  end

  def start
    competitors_count = User.competitors.count
    update_attributes(round: FIRST_ROUND, max_correct_users_count: [competitors_count, 5].min)
  end

  def next_round
    update_attribute(:round, round + 1)
  end

  def finish
    update_attribute(:ongoing, false)
  end

  def refresh_correct_counter
    return if first_round?

    new_max_correct_users_counter = prev_round_winners.count - 1

    update_attribute(:max_correct_users_count, new_max_correct_users_counter)
  end

  def current_competitors
    return User.competitors if round == FIRST_ROUND

    correct_user_ids = prev_round_winners.desc('_id').limit(max_correct_users_count + 1).pluck(:uid)
    User.in(uid: correct_user_ids)
  end

  def has_winner?
    return false if first_round?

    current_competitors.count <= 1
  end

  def previous_round
    round - 1
  end

  def first_round?
    round == FIRST_ROUND
  end

  private

  def prev_round_winners
    CorrectUser.for_round(previous_round)
  end
end
