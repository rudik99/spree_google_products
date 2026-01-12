import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'

let application

if (typeof window.Stimulus === "undefined") {
  application = Application.start()
  application.debug = false
  window.Stimulus = application
} else {
  application = window.Stimulus
}

import SpreeGoogleProductsController from 'spree_google_products/controllers/spree_google_products_controller' 

application.register('spree_google_products', SpreeGoogleProductsController)