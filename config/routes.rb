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
      resources :roles
      resources :users
      resources :event_users
    end
  end
end
