# Only run this if Sprockets is loaded (Spree 4.x / 5.0)
if Rails.configuration.respond_to?(:assets) && defined?(Sprockets)
    Rails.application.config.assets.precompile += %w[
    app_icons/welcome_scene.svg
    app_icons/google_logo.svg
    app_icons/google_merchant_logo.svg
  ]
  end