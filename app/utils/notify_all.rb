class NotifyAll
  SUBSCRIBERS_BATCH_SIZE = 5

  include Enumerable

  attr_accessor :subscribers

  def initialize
    @subscribers = User.all.to_a.in_groups_of(SUBSCRIBERS_BATCH_SIZE, false)
  end

  def each(&block)
    subscribers.each do |batch_subscribers|
      batch_subscribers.each do |subscriber|
        block.call(subscriber)
      end

      sleep(1) # prevents >30 messages per seconds(not allowed by Telegram API)
    end
  end
end
