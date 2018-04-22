#frozen_string_literal: true
module GoogleAdapter
  module Spreadsheets
    class InsertRoundWinner < BaseInsert
      INPUT_OPTION = 'USER_ENTERED'
      RANGE_CELL_MAPPING = {
        1 => 'B',
        2 => 'C',
        3 => 'D',
        4 => 'E',
        5 => 'F'
      }.freeze
      CELL_OFFSET = 1

      def initialize(username, tournament, place)
        @username = username
        @tournament = tournament
        @place = place
        @sheet = GoogleAdapter::Spreadsheet.call
      end

      def call
        sheet.update_spreadsheet_value(SPREADSHEET_ID, range, value_range, value_input_option: INPUT_OPTION)
      end

      private

      attr_reader :sheet, :username, :tournament, :place

      def value_range
        Google::Apis::SheetsV4::ValueRange.new(values: [username].each_slice(1))
      end

      def range
        column = RANGE_CELL_MAPPING[tournament.round]
        "#{column}#{place + CELL_OFFSET}"
      end
    end
  end
end
