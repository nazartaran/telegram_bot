FactoryBot.define do
  factory :tournament do
    round 1
    max_correct_users_count 5
    name 'Tournament'
    ongoing true
  end
end
