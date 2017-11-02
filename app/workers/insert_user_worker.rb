class InsertUserWorker
  include Sidekiq::Worker

  def perform(username)
    GoogleAdapter::Spreadsheets::InsertUser.call(username)
  end
end
