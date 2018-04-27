class NotifyAll < Notify
  def initialize
    @subscribers = User.all
  end
end
