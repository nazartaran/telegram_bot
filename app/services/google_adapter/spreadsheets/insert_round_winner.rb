#frozen_string_literal: true
module GoogleAdapter
  module Spreadsheets
    class InsertRoundWinner
      SPREADSHEET_ID = '1YXPjE5PYLTISymiJpy4Fk_AZPbau0rWlSDQx9NTSr4Y'
      INPUT_OPTION = 'USER_ENTERED'
      RANGE_CELL_MAPPING = {
        1 => 'B10:G',
        2 => 'C10:G',
        3 => 'D10:G',
        4 => 'E10:G',
        5 => 'F10:G'
      }.freeze

      def self.call(*args)
        new(*args).call
      end

      def initialize(username, tournament)
        @username = username
        @tournament = tournament
        @sheet = GoogleAdapter::Spreadsheet.call
      end

      def call
        sheet.append_spreadsheet_value(SPREADSHEET_ID, range, value_range, value_input_option: INPUT_OPTION)
      end

      private

      attr_reader :sheet, :username, :tournament

      def value_range
        Google::Apis::SheetsV4::ValueRange.new(values: [username].each_slice(1))
      end

      def range
        RANGE_CELL_MAPPING[tournament.round]
      end
    end
  end
end
