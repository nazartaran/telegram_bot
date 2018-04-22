# frozen_string_literal: true
require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'pathname'
require 'googleauth/stores/file_token_store'

module GoogleAdapter
  class Spreadsheet
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    APPLICATION_NAME = 'Telegram Bot'
    SCOPE = 'https://www.googleapis.com/auth/spreadsheets'
    DEFAULT_USER_ID = 'default'
    CLIENT_SECRETS_PATH = Rails.root.join(*%w(client_secret.json))
    CREDENTIALS_PATH = 'token.yaml'

    def self.call
      new.call
    end

    def initialize
      client_id   = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      @authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      @service    = initialize_service
    end

    def call
      service
    end

    private

    attr_accessor :service, :authorizer

    def initialize_service
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize
      service
    end

    def authorize
      credentials = authorizer.get_credentials(DEFAULT_USER_ID)

      handle_empty_credentials(credentials)
    end

    def handle_empty_credentials(credentials)
      return credentials unless credentials.blank?

      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts I18n.t('google_spreadsheet.empty_creadentials_prompt')
      puts url
      code = gets
      authorizer.get_and_store_credentials_from_code(user_id: DEFAULT_USER_ID, code: code, base_url: OOB_URI)
    end
  end
end
