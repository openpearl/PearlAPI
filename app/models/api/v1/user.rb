class Api::V1::User < ActiveRecord::Base  
  #Setting up user attributes validation
  MAXIMUM_NAME_LENGTH = 50
  MAXIMUM_EMAIL_LENGTH = 255
  MINIMUM_PASSWORD_LENGTH = 6
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  has_secure_password
  
  before_save { 
    self.email = email.downcase 
    if !self.name.nil?
      self.name = name.upcase
    end
  }

  
  validates :name, length: { maximum: MAXIMUM_NAME_LENGTH }
 
  validates :email, presence: true, length: { maximum: MAXIMUM_EMAIL_LENGTH }, 
              format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  
  validates :password, presence: true, length: { minimum: MINIMUM_PASSWORD_LENGTH }
  
  #Given a user object and a TrueVault API key, returns a JSON array representing 
  #the user object created on TrueVault or an error if the user already exists
  def create_tv_user(user_params, api_key)
    @email = user_params[:email].downcase 
    @password = user_params[:password]
    @tvResponse = `curl https://api.truevault.com/v1/users   \
                  -X POST  -u #{api_key}:    \
                  -d "username=#{@email}&password=#{@password}"`
    @tvResponseJSON = ActiveSupport::JSON.decode(@tvResponse)
  end


end
