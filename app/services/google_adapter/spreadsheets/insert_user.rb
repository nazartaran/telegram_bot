#frozen_string_literal: true
module GoogleAdapter
  module Spreadsheets
    class InsertUser
      SPREADSHEET_ID = '1YXPjE5PYLTISymiJpy4Fk_AZPbau0rWlSDQx9NTSr4Y'
      RANGE = 'A10:F'
      INPUT_OPTION = 'USER_ENTERED'

      def self.call(*args)
        new(*args).call
      end

      def initialize(username)
        @username = username
        @sheet = GoogleAdapter::Spreadsheet.call
      end

      def call
        sheet.append_spreadsheet_value(SPREADSHEET_ID, RANGE, value_range, value_input_option: INPUT_OPTION)
      end

      private

      attr_reader :sheet, :username

      def value_range
        Google::Apis::SheetsV4::ValueRange.new(values: [username].each_slice(1))
      end
    end
  end
end
