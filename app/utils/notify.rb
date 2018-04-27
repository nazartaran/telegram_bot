class Notify
  SUBSCRIBERS_BATCH_SIZE = 25

  include Enumerable

  attr_accessor :subscribers

  def each(&block)
    subscribers.to_a.in_groups_of(SUBSCRIBERS_BATCH_SIZE, false).each do |batch_subscribers|
      Thread.new do
        batch_subscribers.each do |subscriber|
          block.call(subscriber) rescue nil # in case someone blocked bot
        end
      end
      sleep(1) # prevents >30 messages per seconds(not allowed by Telegram API)
    end
  end
end
