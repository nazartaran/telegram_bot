class Notify
  SUBSCRIBERS_BATCH_SIZE = 25

  include Enumerable

  attr_reader :subscribers

  def each(&block)
    batches = subscribers.to_a.in_groups_of(SUBSCRIBERS_BATCH_SIZE, false)
    count = batches.count
    batches.each_with_index do |batch_subscribers, i|
      Thread.new do
        batch_subscribers.each do |subscriber|
          begin
            block.call(subscriber)
          # in case someone blocked bot or other trouble
          rescue => e
            Rails.logger.warn "The problem with sending message to CHAT_ID: #{subscriber.chat_id}, details: #{e.message}"
          end
        end
      end
      sleep(1) unless i == count - 1 # prevents >30 messages per seconds(not allowed by Telegram API)
    end
  end
end
