class InsertUsersWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    GoogleAdapter::Spreadsheets::InsertUsers.call
  end
end
