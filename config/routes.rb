Rails.application.routes.draw do
  get 'sessions/new'
  namespace 'api' do
    scope 'v1' do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
          registrations: 'api/v1/auth/registrations'
      }
    end
    namespace 'v1' do
        resources :events
        resources :posts
        resources :reviews
        resources :roles
        # resources :users
    end
  end
end
