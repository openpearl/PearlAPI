
class ApplicationController < ActionController::API
  
  # pearlmoduleMovePath = File.expand_path('../../../../PearlModules/openpearl_move/lib', __FILE__)
  # $LOAD_PATH.unshift(pearlmoduleMovePath)
  # require 'openpearl_move'
  
  @@tvAccountID = ENV["TV_ACCOUNT_ID"]
  @@tvAdminAPI = ENV["TV_ADMIN_API_KEY"]
  @@tvVaultID = ENV["TV_VAULT_ID"]
  @@tvSchemaID = ENV["TV_SCHEMA_ID"]
end
