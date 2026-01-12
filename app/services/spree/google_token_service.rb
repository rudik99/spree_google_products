require 'signet/oauth_2/client'

module Spree
  class GoogleTokenService
    class TokenError < StandardError; end

    def initialize(credential)
      @credential = credential
    end

    def token
      raise TokenError, "No Google Credential found" unless @credential
      raise TokenError, "Google Account disconnected (missing refresh token)" unless @credential.active?
      if @credential.expired? || (@credential.token_expires_at < 1.minute.from_now)
        refresh!
      end

      @credential.access_token
    end

    private

    def refresh!
      Rails.logger.info "GOOGLE OAUTH: Access Token expired. Refreshing..."

      client = Signet::OAuth2::Client.new(
        token_credential_uri: 'https://oauth2.googleapis.com/token',
        client_id: ENV['GOOGLE_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CLIENT_SECRET'],
        refresh_token: @credential.refresh_token
      )

      begin
        new_token_data = client.fetch_access_token!
        expires_in = new_token_data['expires_in'].to_i
        expires_in = 3600 if expires_in <= 0
        
        update_attributes = {
          access_token: new_token_data['access_token'],
          token_expires_at: Time.current + expires_in.seconds
        }

        if new_token_data['refresh_token'].present?
          update_attributes[:refresh_token] = new_token_data['refresh_token']
        end

        @credential.update!(update_attributes)
        
        Rails.logger.info "GOOGLE OAUTH: Token refreshed successfully."
      rescue Signet::AuthorizationError => e
        Rails.logger.error "GOOGLE OAUTH: Refresh failed. User likely revoked access. Error: #{e.message}"
        raise TokenError, "Could not refresh token. Please reconnect Google Account."
      rescue => e
        Rails.logger.error "GOOGLE OAUTH: Generic Error during refresh: #{e.message}"
        raise e
      end
    end
  end
end