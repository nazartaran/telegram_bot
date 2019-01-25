#frozen_string_literal: true
module GoogleAdapter
  module Spreadsheets
    class InsertUsers < BaseInsert
      RANGE = 'A2:F'
      INPUT_OPTION = 'USER_ENTERED'

      def initialize
        @sheet = GoogleAdapter::Spreadsheet.call
      end

      def call
        values = User.competitors.map { |user| [user.full_name] }
        value_range_object = Google::Apis::SheetsV4::ValueRange.new(range: RANGE,
                                                                    values: values)
        sheet.update_spreadsheet_value(SPREADSHEET_ID,
                                       RANGE,
                                       value_range_object,
                                       value_input_option: INPUT_OPTION)
      end

      private

      attr_reader :sheet, :username

      def value_range
        Google::Apis::SheetsV4::ValueRange.new(values: [username].each_slice(1))
      end
    end
  end
end
