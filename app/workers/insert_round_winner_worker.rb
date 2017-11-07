class InsertRoundWinnerWorker
  include Sidekiq::Worker

  def perform(username, place)
    GoogleAdapter::Spreadsheets::InsertRoundWinner.call(username, Tournament.ongoing, place)
  end
end
