class User < ActiveRecord::Base  
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User
  has_one :document, dependent: :destroy
  has_one :access_token, dependent: :destroy
  has_many :blobs, dependent: :destroy
  
  #Setting up user attributes validation
  MAXIMUM_EMAIL_LENGTH = 255
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :email, presence: true, length: { maximum: MAXIMUM_EMAIL_LENGTH }, 
              format: { with: VALID_EMAIL_REGEX }
 
  
  #Given a user object and a TrueVault API key, returns a JSON array representing 
  #the user object created on TrueVault or an error if the user already exists
  def create_tv_user(sign_up_params, api_key)
    email = sign_up_params[:email].downcase 
    password = sign_up_params[:password]
    tvResponse = `curl https://api.truevault.com/v1/users   \
                  -X POST  -u #{api_key}:    \
                  -d "username=#{email}&password=#{password}"`
    tvResponseJSON = JSON.parse(tvResponse)
  end


  #Initializes a document for a new user. This document holds all their personal information
  #as base64 encoded JSON strings.
  #TODO: Update this document encoding if schema changes
  def initialize_tv_user_document(user, vault_id, api_key, schema_id)
    tvresponse =  `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents \
                  -u #{api_key}: \
                  -X POST \
                  -d "document=e30="`
    tvResponseJSON = JSON.parse(tvresponse)
    tvDocumentID = tvResponseJSON["document_id"]
    userID = user.id
    tvDocument = Document.create(:documentID => tvDocumentID, :user_id => userID)    
  end

end
