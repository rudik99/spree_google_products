module Spree
  class GoogleCredential < Spree::Base
    belongs_to :store, class_name: 'Spree::Store'

    validates :merchant_center_id, presence: true, on: :update
    
    validates :target_country, length: { is: 2 }, allow_blank: true
    validates :target_currency, length: { is: 3 }, allow_blank: true

    validates :store_id, presence: true, uniqueness: true
    
    if respond_to?(:encrypts)
      encrypts :access_token
      encrypts :refresh_token
    end

    def active?
      refresh_token.present?
    end

    def expired?
      token_expires_at.nil? || token_expires_at <= Time.current
    end

    def ready_for_sync?
      active? && merchant_center_id.present?
    end
  end
end