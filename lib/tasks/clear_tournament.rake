task clear_tournament: :environment do
  User.update_all(competes_in_tournament: false)
  CorrectUser.delete_all
  Tournament.delete_all
end
