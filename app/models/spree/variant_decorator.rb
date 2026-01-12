module Spree
    module VariantDecorator
      def self.prepended(base)
        base.has_one :google_variant_attribute, class_name: 'Spree::GoogleVariantAttribute', dependent: :destroy
      end
    end
  end
  Spree::Variant.prepend(Spree::VariantDecorator)