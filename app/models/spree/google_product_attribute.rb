module Spree
    class GoogleProductAttribute < Spree::Base
      belongs_to :product, class_name: 'Spree::Product'
      serialize :google_issues, coder: JSON
      validates :gender, inclusion: { in: %w[male female unisex], allow_blank: true }
      validates :age_group, inclusion: { in: %w[adult kids toddler infant], allow_blank: true }
      validates :condition, inclusion: { in: %w[new refurbished used], allow_blank: true }
    end
  end