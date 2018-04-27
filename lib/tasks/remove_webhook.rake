task remove_webhook: :environment do
  Telegram.bots.first.last.set_webhook(url: nil)
end
