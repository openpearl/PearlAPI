Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
      resources :users, except: [:new, :edit]
      patch 'documents/:id'   => 'documents#update', as: :document
      post 'communications'   => 'communications#converse', as: :communicate
      # get    'login'          => 'sessions#new'
      # post   'login'          => 'sessions#create'
      # delete 'logout'         => 'sessions#destroy'
    end
  end
end
