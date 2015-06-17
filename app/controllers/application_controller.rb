class ApplicationController < ActionController::API
  @@tvAccountID = ENV["TV_ACCOUNT_ID"]
  @@tvAdminAPI = ENV["TV_ADMIN_API_KEY"]
end
