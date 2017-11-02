class InsertRoundWinnerWorker
  include Sidekiq::Worker

  def perform(username)
    ongoing_tournament = Tournament.ongoing

    GoogleAdapter::Spreadsheets::InsertRoundWinner.call(username, ongoing_tournament)
  end
end
