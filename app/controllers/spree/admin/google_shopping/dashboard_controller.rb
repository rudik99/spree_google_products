module Spree
  module Admin
    module GoogleShopping
      class DashboardController < Spree::Admin::BaseController
        helper Spree::Admin::BaseHelper
        
        before_action :check_connection, only: [:index]

        def index
          @store = Spree::Store.default
          @credential = @store.google_credential

          if @credential&.active? && @credential.merchant_center_id.present?
            service = Spree::GoogleShopping::StatusService.new(@credential)
            @stats = service.fetch_counts
            @last_sync = @credential.last_sync_at
            
            if @stats[:error]
              flash.now[:error] = "Could not fetch live stats from Google. Showing cached or empty data."
            end
          else

            @stats = { approved: 0, limited: 0, pending: 0, disapproved: 0 }
            @last_sync = nil
          end
        end

        def sync
          products = Spree::Product.all
          @store = Spree::Store.default
          
          if products.empty?
            flash[:error] = "No products found to sync."
          elsif @store.google_credential.merchant_center_id.blank?
            flash[:error] = "Please enter your Google Merchant Center ID in Settings before syncing."
          else
            products.each do |product|
              Spree::GoogleShopping::SyncProductJob.perform_later(product.id)
            end
            
            if @store.google_credential&.merchant_center_id
              Rails.cache.delete("google_shopping_stats_#{@store.google_credential.merchant_center_id}")
            end
            
            flash[:success] = "Sync started for #{products.count} products! Statuses will update shortly."
          end

          redirect_to admin_google_shopping_dashboard_path
        end

        private

        def check_connection
          credential = Spree::Store.default.google_credential
          
          unless credential&.active?
            flash[:warning] = "Please connect your Google Merchant Center account to access the dashboard."
            redirect_to edit_admin_google_merchant_settings_path
          end
        end
      end
    end
  end
end