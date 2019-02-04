module Tournaments
  module QuestionTester
    def self.call(bot)
      user = User.find_by_name('Kiril', 'Dokh')

      (1..5).each do |round|
        question = Question.for_round(round).body
        # "\"Lorem\" is just a \"word\"" => "«Lorem» is just a «word»"
        escaped_question = question.gsub(/(\")([^\"]+?)(\")/, '«\2»')

        begin
          bot.send_message(chat_id: user.chat_id, text: "#{round}: #{escaped_question}")
        rescue => e
          Rails.logger.warn "The problem with sending message to CHAT_ID: #{user.chat_id}, details: #{e.message}"
        end
      end
    end
  end
end
