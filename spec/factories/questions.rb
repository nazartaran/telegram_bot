FactoryBot.define do
  factory :question do
    body 'Question?'
    answers ['true', '1', 'yes', 'of course']
    for_tournament true
    round 1
  end
end
