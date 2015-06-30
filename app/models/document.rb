class Document < ActiveRecord::Base
  #TODO set up the truevault schema when ready for production
  belongs_to :user


  # Given document parameters, checks to see if the TrueVault document
  # has corresponding parameters by comparing the keys of the parameter
  # to the keys of the TrueVault document object. Fields in the TrueVault
  # document which is found to have a matching key are modified to reflect
  # the value of assoicated with the key passed by the parameter.
  def update_document(document_params, document_id, vault_id, api_key)
    
    # Retrieves the truevault document for the current user and returns a base 64 encoded JSON string
    tvDocBase64 = `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{document_id} \
                  -X GET \
                  -u #{api_key}:`
    
    # Decode the encoded JSON string             
    tvDocDecode = Base64.decode64(tvDocBase64) 
    
    # Parse the decoded string as a JSON hash
    tvDocDecodeJson = JSON.parse(tvDocDecode)
    
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
    `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{document_id} \
    -u #{api_key}: \
    -X PUT \
    -d "document=#{tvDocEncode}"`
   
    # Return the updated document
    return tvDocDecodeJson
  end
end
