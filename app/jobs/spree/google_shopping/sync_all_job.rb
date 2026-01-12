module Spree
    module GoogleShopping
      class SyncAllJob < SpreeGoogleProducts::BaseJob
        #queue_as :default
  
        def perform
          credential = Spree::Store.default.google_credential
          return unless credential&.active?
  
          service = Spree::GoogleShopping::ContentService.new(credential)
          
          Spree::Product.active.find_each(batch_size: 50) do |product|
            service.push_product(product)
          end
        end
      end
    end
  end