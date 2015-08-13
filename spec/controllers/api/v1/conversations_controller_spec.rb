require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, type: :controller do
  describe "GET #get_guest_token" do
    it "responds successfully with an HTTP 200 status code" do
      get :get_guest_token
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end
end
