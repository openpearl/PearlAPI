class Document < ActiveRecord::Base
  belongs_to :user
  
  # Creates a new document in TrueVault with an empty hash as it's value.
  # Returns a json representation of the TrueVault response.
  def create_tv_document(vault_id, api_key)
    tvResponse =  `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents \
                  -u #{api_key}: \
                  -X POST \
                  -d "document=e30="`
    # Parse and return a json hash of the TrueVault response
    tvResponseJSON = JSON.parse(tvResponse)   
  end
  
  
  # Reads the TrueVault document belonging to the current user.
  # Returns a json representation of the TrueVault doucment.
  def read_tv_document(vault_id, api_key)
    # Retrieves the TrueVault document for the current user and returns a base 64 encoded JSON string
    tvDocBase64 = `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{self.documentID} \
                  -X GET \
                  -u #{api_key}:`
    
    # Decode the encoded JSON string             
    tvDocDecode = Base64.decode64(tvDocBase64) 
    
    # Parse the decoded string as a JSON hash
    tvDocDecodeJson = JSON.parse(tvDocDecode)   
  end


  # Given document parameters, checks to see if the TrueVault document
  # has corresponding parameters by comparing the keys of the parameter
  # to the keys of the TrueVault document object. Fields in the TrueVault
  # document which is found to have a matching key are modified to reflect
  # the value of assoicated with the key passed by the parameter.
  # Returns a json hash of the updated document
  def update_tv_document(document_params, vault_id, api_key)
    tvDocDecodeJson = self.read_tv_document(vault_id, api_key)
    
    # For each key in the parameters, check if it already exists in the Truevault document.
    # If the key exists and its value is an array, append the new values.
    # Otherwise, update the key-value pair or add it if it does not exist.
    document_params.keys.each do |key|
      if tvDocDecodeJson.key?(key) and tvDocDecodeJson[key].class == Array
        document_params[key].each do |value|
          tvDocDecodeJson[key].append(value)
        end
      else
        tvDocDecodeJson[key] = document_params[key]
      end
    end      
    
    # Encode the updated document as a base 64 encoded JSON string.
    tvDocEncode = Base64.encode64(tvDocDecodeJson.to_json) 
    
    # Update the document on truevualt.
    `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{self.documentID} \
    -u #{api_key}: \
    -X PUT \
    -d "document=#{tvDocEncode}"`
   
    # Return the updated document as a json hash
    return tvDocDecodeJson
  end
  
  
  # Destroy the TrueVault document
  # Returns a json representation of the TrueVault response.
  def destroy_tv_document(vault_id, api_key)
    tvResponse = `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{self.documentID} \
                  -X DELETE \
                  -u #{api_key}:`
    # Parse and return a json hash of the TrueVault response
    tvResponseJSON = JSON.parse(tvResponse)               
  end
  
  
  # Reset the TrueVault document to an empty json hash
  def reset_tv_document(vault_id, api_key)
    tvResponse = `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{self.documentID} \
    -u #{api_key}: \
    -X PUT \
    -d "document=e30="`
    
    # Parse and return a json hash of the TrueVault response
    tvResponseJSON = JSON.parse(tvResponse) 
  end
end
