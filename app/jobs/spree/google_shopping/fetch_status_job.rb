module Spree
  module GoogleShopping
    class FetchStatusJob < SpreeGoogleProducts::BaseJob
      #queue_as :default

      def perform
        credential = Spree::Store.default.google_credential
        return unless credential&.active?

        service = Spree::GoogleShopping::ContentService.new(credential)
        
        Spree::GoogleVariantAttribute.where.not(google_status: nil).find_each(batch_size: 50) do |g_attr|
          variant = Spree::Variant.find_by(id: g_attr.variant_id)
          next unless variant
          
          service.fetch_product_status(variant)
          
          sleep 0.2
        end
      end
    end
  end
end