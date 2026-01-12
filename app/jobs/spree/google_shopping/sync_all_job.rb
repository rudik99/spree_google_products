module Spree
  module GoogleShopping
    class SyncAllJob < SpreeGoogleProducts::BaseJob
      queue_as :default

      def perform
        credential = Spree::Store.default.google_credential
        
        unless credential&.active?
          Rails.logger.warn "GOOGLE SYNC ALL: Credential missing or inactive. Aborting."
          return
        end
          
        count = 0
        Spree::Product.active.find_each do |product|
          Spree::GoogleShopping::SyncProductJob.perform_later(product.id)
          count += 1
        end
        Rails.logger.info "GOOGLE SYNC ALL: Successfully queued background sync for #{count} products."
      end
    end
  end
end
