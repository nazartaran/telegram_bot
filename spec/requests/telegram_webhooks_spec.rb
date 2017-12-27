RSpec.describe TelegramWebhooksController, :telegram_bot do
  describe '#register' do
    subject { -> { dispatch_message '/register' } }
    it { is_expected.to respond_with_message 'Ви успішно зареєструвалися на наш черговий турнір. Очікуйте на запитання!' }
  end
end
