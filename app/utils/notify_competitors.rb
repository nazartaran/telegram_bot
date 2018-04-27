class NotifyCompetitors < Notify
  def initialize
    @subscribers = User.competitors
  end
end
