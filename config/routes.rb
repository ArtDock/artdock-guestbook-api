Rails.application.routes.draw do
  get 'sessions/new'
  namespace 'api' do
    namespace 'v1' do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
          registrations: 'api/v1/auth/registrations'
      }
      resources :events
      resources :posts
      resources :reviews

      resources :roles do
        collection do
          post :set_user_role
        end
      end

      resources :users do
        collection do
            get :my_page
        end
      end
      resources :event_users

      resource :token_mints do
        collection do
          post :mint_to_user
        end
      end

      resources :poap_gating  do
        collection do
          post :gating_test
          post :post_review
        end
      end

    end
  end
end
