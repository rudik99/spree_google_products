require 'signet/oauth_2/client'
require 'net/http'
require 'json'
require 'openssl'

module Spree
  module Admin
    class GoogleMerchantSettingsController < ResourceController
      helper Spree::Admin::GoogleShoppingHelper 
      
      def model_class
        Spree::GoogleCredential
      end

      def edit
        @credential = current_store.google_credential || current_store.build_google_credential
      end

      def update
        @credential = current_store.google_credential || current_store.build_google_credential
        
        if @credential.update(permitted_params)
          Spree::GoogleShopping::SyncAllJob.perform_later
          
          flash[:success] = Spree.t(:successfully_updated, resource: 'Google Settings')
          redirect_to spree.edit_admin_google_merchant_settings_path
        else
          flash[:error] = "Failed to save settings. Please check the errors below."
          render :edit
        end
      end

      def connect
        redirect_uri = spree.callback_admin_google_merchant_settings_url
        Rails.logger.info "GOOGLE CONNECT: Generated Redirect URI: #{redirect_uri}"

        client = Signet::OAuth2::Client.new(
          authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
          token_credential_uri: 'https://oauth2.googleapis.com/token',
          client_id: ENV['GOOGLE_CLIENT_ID'],
          client_secret: ENV['GOOGLE_CLIENT_SECRET'],
          scope: [
            'https://www.googleapis.com/auth/content',
            'https://www.googleapis.com/auth/adwords',
            'https://www.googleapis.com/auth/userinfo.email'
          ],
          redirect_uri: redirect_uri,
          additional_parameters: { 
            access_type: 'offline',
            prompt: 'consent'
          }
        )
        redirect_to client.authorization_uri.to_s, allow_other_host: true
      end

      def callback
        Rails.logger.info "GOOGLE CALLBACK: Received parameters: #{params.inspect}"

        if params[:error].present?
          flash[:error] = "Google Access Denied: #{params[:error]}"
          return redirect_to spree.edit_admin_google_merchant_settings_path
        end

        if params[:code].blank?
          flash[:error] = "No code received from Google."
          return redirect_to spree.edit_admin_google_merchant_settings_path
        end

        redirect_uri = spree.callback_admin_google_merchant_settings_url

        client = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://oauth2.googleapis.com/token',
          client_id: ENV['GOOGLE_CLIENT_ID'],
          client_secret: ENV['GOOGLE_CLIENT_SECRET'],
          redirect_uri: redirect_uri,
          code: params[:code]
        )
        begin
          response = client.fetch_access_token!
          
          Rails.logger.info "GOOGLE TOKEN: Success! Expires in: #{response['expires_in']}"

          access_token = response['access_token']
          expires_in = response['expires_in'].to_i
          expires_in = 3600 if expires_in <= 0

          email = fetch_google_email(access_token)

          cred = current_store.google_credential || current_store.build_google_credential
          
          new_refresh_token = response['refresh_token'].presence || cred.refresh_token

          cred.assign_attributes(
            access_token: access_token,
            refresh_token: new_refresh_token,
            token_expires_at: Time.current + expires_in.seconds,
            scope: response['scope'],
            email: email,
            store: current_store
          )
          
          if cred.save(validate: false)
            flash[:success] = "Google Account (#{email}) Connected Successfully!"
          else
            Rails.logger.error "DB ERROR: #{cred.errors.full_messages}"
            flash[:error] = "Database Error: #{cred.errors.full_messages.join(', ')}"
          end
          
          redirect_to spree.edit_admin_google_merchant_settings_path

        rescue Signet::AuthorizationError => e

          current_cred = current_store.google_credential
          if current_cred&.active? && current_cred.updated_at > 2.minutes.ago
            Rails.logger.warn "GOOGLE: Race condition detected (invalid_grant ignored). Login was successful."
            
            connected_email = current_cred.email || "Google Account"
            flash[:success] = "Google Account (#{connected_email}) Connected Successfully!"
            
            redirect_to spree.edit_admin_google_merchant_settings_path
            return
          end
          
          Rails.logger.error "GOOGLE AUTH ERROR: #{e.message}"
          flash[:error] = "Google Authorization Failed: #{e.message}"
          redirect_to spree.edit_admin_google_merchant_settings_path
          
        rescue => e
          Rails.logger.error "GOOGLE GENERIC ERROR: #{e.message}"
          flash[:error] = "Error: #{e.message}"
          redirect_to spree.edit_admin_google_merchant_settings_path
        end
      end

      def disconnect
        cred = current_store.google_credential
        if cred&.destroy
          flash[:success] = "Google Account Disconnected."
        else
          flash[:error] = "Could not disconnect account."
        end
        redirect_to spree.edit_admin_google_merchant_settings_path
      end

      private

      def fetch_google_email(access_token)
        uri = URI('https://www.googleapis.com/oauth2/v2/userinfo')
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{access_token}"
        request['User-Agent'] = "SpreeGoogleShopping/1.0"
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          http.request(request)
        end

        if response.is_a?(Net::HTTPSuccess)
          data = JSON.parse(response.body)
          data['email']
        else
          Rails.logger.warn "GOOGLE EMAIL FETCH FAILED: #{response.code} - #{response.body}"
          "Connected Account"
        end
      rescue => e
        Rails.logger.error "GOOGLE EMAIL FETCH ERROR: #{e.message}"
        "Connected Account"
      end

      def permitted_params
        params.require(:google_credential).permit(
          :merchant_center_id, 
          :ad_account_id,
          :target_country,
          :target_currency,
          :default_product_type,
          :default_google_product_category,
          :default_min_handling_time, 
          :default_max_handling_time
        )
      end
    end
  end
end