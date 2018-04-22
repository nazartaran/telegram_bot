# frozen_string_literal: true

require 'csv'
require 'open-uri'

module QuestionsImporter
  URL_PREFIX = 'https://api.telegram.org/file/bot'

  def self.success?(path)
    response = RestClient.get("#{URL_PREFIX}#{Rails.application.secrets.telegram['bot']['token']}/#{path}").body

    questions = CSV.new(response).each_with_index.map do |row, index|
      body, *answers = row.reject { |cell| cell.strip.blank? }.map { |cell| cell.force_encoding('utf-8') }
      Question.new(body: body, answers: answers, round: index + 1) unless index >= 5
    end.compact

    if questions.all?(&:valid?)
      questions.each(&:save!)
      true
    else
      false
    end
  rescue
    false
  end
end
