module Spree
    class GoogleVariantAttribute < Spree::Base
      belongs_to :variant, class_name: 'Spree::Variant'
      serialize :google_issues, coder: JSON
    end
  end