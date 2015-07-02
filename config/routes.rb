# Allows us to control which version of the api we are using.
require 'api_constraints'

Rails.application.routes.draw do
  scope module: :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations:  'api/v1/devise_controller_mod/registrations'
      }
      resources :users, except: [:new, :edit]
      patch 'documents'   => 'documents#update', as: :document_update
      patch 'documents/reset'   => 'documents#reset', as: :document_reset
      post 'communications'   => 'communications#converse', as: :communicate
    end
  end
  
  root 'application#test'
end
