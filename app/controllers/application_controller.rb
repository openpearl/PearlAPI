class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::MimeResponds
  include ActionController::StrongParameters
  
  protect_from_forgery with: :null_session
  
  @@tvAccountID = ENV["TV_ACCOUNT_ID"]
  @@tvAdminAPI = ENV["TV_ADMIN_API_KEY"]
  @@tvVaultID = ENV["TV_VAULT_ID"]
  @@tvSchemaID = ENV["TV_SCHEMA_ID"]
  
  def home
    render json: "placeholder root", status: 200
  end
end
