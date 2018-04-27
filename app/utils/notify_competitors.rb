class NotifyCompetitors < Notify
  def subscribers
    User.competitors
  end
end
