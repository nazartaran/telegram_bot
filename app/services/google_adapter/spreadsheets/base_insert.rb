#frozen_string_literal: true
module GoogleAdapter
  module Spreadsheets
    class BaseInsert
      SPREADSHEET_ID = Rails.application.secrets[:spreadsheet_id]

      def self.call(*args)
        new(*args).call
      end

      private

      def call
        raise 'Method call must be implemented'
      end
    end
  end
end
