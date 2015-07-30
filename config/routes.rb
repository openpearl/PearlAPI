# Allows us to control which version of the api we are using.
require 'api_constraints'

Rails.application.routes.draw do
  scope module: :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations:  'api/v1/devise_controller_mod/registrations'
      }
      mount PearlEngine::Engine, at: "/pearl"
      get 'goals'              => 'settings#showGoals', as: :goals
      patch 'goals'            => 'settings#updateGoals', as: :goals_update
      get 'documents'          => 'documents#read', as: :document_read
      patch 'documents'        => 'documents#update', as: :document_update
      patch 'documents/reset'  => 'documents#reset', as: :document_reset
      post 'documents'         => 'documents#query', as: :document_query
      post 'converse'          => 'conversations#converse', as: :converse
      get 'context'            => 'conversations#getContextUpdateRequirements', as: :context
      post 'context'           => 'conversations#syncContext', as: :sync 
      get 'test' => 'conversations#test', as: :test
    end
  end
  
  root 'application#test'
end
