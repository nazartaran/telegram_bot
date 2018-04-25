task clear_tournament: :environment do
  Tournaments::Close.now
end
