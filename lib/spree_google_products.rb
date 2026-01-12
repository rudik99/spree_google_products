require 'spree_core'
require 'spree_extension'
require 'spree_google_products/engine'
require 'spree_google_products/version'
require 'spree_google_products/configuration'

module SpreeGoogleProducts
  mattr_accessor :queue

  def self.queue
    @@queue ||= (defined?(Spree.queues) ? Spree.queues.default : :default)
  end
end