class AccessToken < ActiveRecord::Base
  belongs_to :user
  before_create :generate_access_token
  
  
  private
  
    def generate_access_token

    end
end
