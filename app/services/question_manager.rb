module QuestionManager
  def self.up_to_date
    Question.last_played_set.each { |question| question.update(outdated: false) }
  end
end
