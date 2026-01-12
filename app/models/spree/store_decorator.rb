module Spree
    module StoreDecorator
      def self.prepended(base)
        base.has_one :google_credential, class_name: 'Spree::GoogleCredential', dependent: :destroy
      end
    end
  end
  
  ::Spree::Store.prepend(Spree::StoreDecorator)