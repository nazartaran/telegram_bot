FactoryBot.define do
  factory :user do
    first_name 'Olexandr'
    last_name 'Drudz'
    username 'o_druz'
    language_code 'en'
    uid nil
    chat_id nil
    round nil
    competes_in_tournament false
    is_bot false
  end
end
