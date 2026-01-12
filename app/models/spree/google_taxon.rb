module Spree
    class GoogleTaxon < Spree::Base
      validates :google_id, presence: true, uniqueness: true
    end
  end