module Spree
  module GoogleShopping
    class SyncProductJob < SpreeGoogleProducts::BaseJob
      #queue_as :default

      def perform(product_id)
        product = Spree::Product.find_by(id: product_id)
        unless product
          Rails.logger.error "GOOGLE SYNC JOB: Product ID #{product_id} not found."
          return
        end

        credential = Spree::Store.default.google_credential
        unless credential&.active?
          Rails.logger.warn "GOOGLE SYNC JOB: Credential missing or inactive. Aborting."
          return
        end

        Rails.logger.info "GOOGLE SYNC JOB: Starting sync for Product '#{product.name}' (ID: #{product.id})..."
        
        begin
          service = Spree::GoogleShopping::ContentService.new(credential)
          service.push_product(product)

          credential.update_column(:last_sync_at, Time.current)
          
          Rails.logger.info "GOOGLE SYNC JOB: ✅ Completed successfully for Product #{product.id}."
        rescue => e
          Rails.logger.error "GOOGLE SYNC JOB: ❌ Failed for Product #{product.id}. Error: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end
  end
end