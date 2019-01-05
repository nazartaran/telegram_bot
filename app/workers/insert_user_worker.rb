class InsertUserWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(username)
    GoogleAdapter::Spreadsheets::InsertUser.call(username)
  end
end
