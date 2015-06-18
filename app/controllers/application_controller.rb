class ApplicationController < ActionController::API
  @@tvAccountID = ENV["TV_ACCOUNT_ID"]
  @@tvAdminAPI = ENV["TV_ADMIN_API_KEY"]
  @@tvVaultID = ENV["TV_VAULT_ID"]
  @@tvSchemaID = ENV["TV_SCHEMA_ID"]
end
