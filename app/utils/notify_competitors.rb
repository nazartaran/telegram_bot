class NotifyCompetitors
  def initialize
    @subscribers = User.competitors
  end
end
