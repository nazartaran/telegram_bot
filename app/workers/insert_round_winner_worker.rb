class InsertRoundWinnerWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(username, place)
    GoogleAdapter::Spreadsheets::InsertRoundWinner.call(username, Tournament.ongoing, place)
  end
end
