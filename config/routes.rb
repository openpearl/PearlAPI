Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :users, except: [:new, :edit]
      patch 'documents/:id', to: 'documents#update', as: :document
      post 'communications', to: 'communications#converse', as: :communicate
    end
  end
end
