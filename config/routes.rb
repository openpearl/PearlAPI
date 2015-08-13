# Allows us to control which version of the api we are using.
require 'api_constraints'

Rails.application.routes.draw do
  scope module: :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations:  'api/v1/devise_controller_mod/registrations'
      }
      mount PearlEngine::Engine, at: "/pearl"
      get 'goals'              => 'goals#show', as: :goals
      patch 'goals'            => 'goals#update', as: :goals_update
      get 'documents'          => 'documents#read', as: :document_read
      patch 'documents'        => 'documents#update', as: :document_update
      patch 'documents/reset'  => 'documents#reset', as: :document_reset
      post 'documents'         => 'documents#query', as: :document_query
      get 'guest_token'        => 'conversations#get_guest_token', as: :guest_token
      post 'converse'          => 'conversations#converse', as: :converse
      get 'context'            => 'conversations#getContextUpdateRequirements', as: :context
      post 'context'           => 'conversations#syncContext', as: :sync 
      get 'context/graphs'     => 'conversations#showGraphData', as: :graph 
    end
  end
  
  root 'application#home'
end
