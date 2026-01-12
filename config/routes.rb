Spree::Core::Engine.add_routes do
  namespace :admin do
    # Dashboard
    namespace :google_shopping do
      get 'dashboard', to: 'dashboard#index', as: :dashboard
      resources :issues, only: [:index]
      post 'sync', to: 'dashboard#sync', as: :sync
      
      # Dedicated Product Manager
      resources :products, only: [:index, :edit, :update] do
        member do
          post :sync_one
          get :issues
        end
      end

      # Taxonomy Search
      resources :taxons, only: [] do
        collection do
          get :drill_down
        end
      end
    end

    # Settings Routes
    resource :google_merchant_settings, only: [:edit, :update] do
      get :connect
      get :callback
      delete :disconnect
      post :sync_now
    end
  end
end