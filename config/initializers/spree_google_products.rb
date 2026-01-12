Rails.application.config.after_initialize do
    if Spree.respond_to?(:admin) && Spree.admin.respond_to?(:navigation)
      sidebar = Spree.admin.navigation.sidebar
      sidebar.add :google_shopping, 
        label: 'Google Shopping', 
        icon: 'brand-google', 
        url: :admin_google_shopping_dashboard_path, 
        position: 85
      sidebar.add :google_dashboard, 
        parent: :google_shopping, 
        label: 'Dashboard', 
        url: :admin_google_shopping_dashboard_path, 
        active: -> { params[:controller].include?('google_shopping/dashboard') }
      sidebar.add :google_products, 
        parent: :google_shopping, 
        label: 'Products', 
        url: :admin_google_shopping_products_path, 
        active: -> { params[:controller].include?('google_shopping/products') }
      sidebar.add :google_settings, 
        parent: :google_shopping, 
        label: :settings, 
        url: :edit_admin_google_merchant_settings_path, 
        active: -> { controller_name == 'google_merchant_settings' }
    end
    
    if defined?(Spree::Ability) && defined?(SpreeGoogleProducts::Ability)
      Spree::Ability.register_ability(SpreeGoogleProducts::Ability)
    end
  end