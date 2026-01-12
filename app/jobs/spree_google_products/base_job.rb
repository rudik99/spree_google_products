module SpreeGoogleProducts
  class BaseJob < Spree::BaseJob
    queue_as SpreeGoogleProducts.queue
  end
end