pin 'application-spree-google-products', to: 'spree_google_products/application.js', preload: false

pin_all_from SpreeGoogleProducts::Engine.root.join('app/javascript/spree_google_products/controllers'),
             under: 'spree_google_products/controllers',
             to:    'spree_google_products/controllers',
             preload: 'application-spree-google-products'
