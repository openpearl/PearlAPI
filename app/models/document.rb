class Document < ActiveRecord::Base
  #TODO set up the truevault schema when ready for production
  belongs_to :user

  # Given document parameters, checks to see if the TrueVault document
  # has corresponding parameters by comparing the keys of the parameter
  # to the keys of the TrueVault document object. Fields in the TrueVault
  # document which is found to have a matching key are modified to reflect
  # the value of assoicated with the key passed by the parameter.
  def update_document(document_params, document_id, vault_id, api_key)
    tvDocBase64 = `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{document_id} \
                  -X GET \
                  -u #{api_key}:`
                  
    tvDocDecode = Base64.decode64(tvDocBase64) 
    tvDocDecodeJson = JSON.parse(tvDocDecode)
     
    document_params[:document].keys.each do |key|
      if tvDocDecodeJson.key?(key) 
        tvDocDecodeJson[key] = document_params[:document][key]
      end
    end      
    
    tvDocEncode = Base64.encode64(tvDocDecodeJson.to_json) 
    
    `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{document_id} \
    -u #{api_key}: \
    -X PUT \
    -d "document=#{tvDocEncode}="`
  end
end
