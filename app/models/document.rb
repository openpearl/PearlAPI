class Document < ActiveRecord::Base
  belongs_to :user

  # Returns a json hash representing a default TrueVault document schema for a Pearl user.
  def get_document_schema
    filePath = Rails.root.join("lib", "base_truevault_doc.json")
    file = File.read(filePath)
    schema = JSON.parse(file).with_indifferent_access
  end


  # Creates a new document in TrueVault for a new user with a given schema, or a blank schema if not specified.
  # Returns a json representation of the TrueVault response.
  def create_tv_document(vault_id, api_key, schema = {})
    schemaToJsonString = schema.to_json
    schemaToBase64 = Base64.encode64(schemaToJsonString)
    tvResponse =  `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents \
                  -u #{api_key}: \
                  -X POST \
                  -d "document=#{schemaToBase64}"`

    # Parse and return a json hash of the TrueVault response
    tvResponseJSON = JSON.parse(tvResponse).with_indifferent_access
  end


  # Reads the TrueVault document belonging to the current user.
  # Returns a json representation of the whole TrueVault document.
  def read_tv_document(vault_id, api_key)
    # Retrieves the TrueVault document for the current user and returns a base 64 encoded JSON string
    tvDocBase64 = `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{self.documentID} \
                  -X GET \
                  -u #{api_key}:`

    # Decode the encoded JSON string
    tvDocDecode = Base64.decode64(tvDocBase64)

    # Parse and return the decoded string as a JSON hash
    tvDocDecodeJson = JSON.parse(tvDocDecode).with_indifferent_access
  end


  # Replaces the data in the TrueVault document belonging to the current user with the new data given
  def update_tv_document(vault_id, api_key, new_data)
    # Encode new_data as a base 64 encoded JSON string.
    tvDocEncode = Base64.encode64(new_data.to_json)

    # Update the document on TrueVault.
    tvResponse =  `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{self.documentID} \
                  -u #{api_key}: \
                  -X PUT \
                  -d "document=#{tvDocEncode}"`

    # Parse and return a json hash of the TrueVault response
    tvResponseJSON = JSON.parse(tvResponse).with_indifferent_access
  end


  # Destroy the TrueVault document
  # Returns a json representation of the TrueVault response.
  def destroy_tv_document(vault_id, api_key)
    tvResponse = `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{self.documentID} \
                  -X DELETE \
                  -u #{api_key}:`
    # Parse and return a json hash of the TrueVault response
    tvResponseJSON = JSON.parse(tvResponse).with_indifferent_access
  end


  # Given document parameters, checks to see if the TrueVault document
  # has corresponding parameters by comparing the keys of the parameter
  # to the keys of the TrueVault document object. Fields in the TrueVault
  # document which is found to have a matching key are modified to reflect
  # the value of assoicated with the key passed by the parameter.
  # Returns a json hash of the updated document
  def get_document_updates(vault_id, api_key, document_params)
    tvDocDecodeJson = self.read_tv_document(vault_id, api_key)

    # For each key in the parameters, check if it already exists in the Truevault document.
    # If the key exists and its value is an array, append the new values.
    # Otherwise, update the key-value pair or add it if it does not exist.
    document_params.keys.each do |key|
      if not document_params[key].nil?
        if tvDocDecodeJson.key?(key) and tvDocDecodeJson[key].class == Array
          document_params[key].each do |value|
            exists = false
            tvDocDecodeJson[key].each do |check|
              if value["UUID"] == check["UUID"]
                value.keys.each do |replace|
                  check[replace] = value[replace]
                end
                exists = true
              end
            end
            if !exists
              tvDocDecodeJson[key].append(value)
            end
          end
        else
          tvDocDecodeJson[key] = document_params[key]
        end
      end
    end

    # Return the updated document as a json hash
    return tvDocDecodeJson
  end


  # Queries the TrueVault document, and returns the queried data
  def query_tv_document(vault_id, api_key, query_params)
    documentData = self.read_tv_document(vault_id, api_key)
    queryData = {}.with_indifferent_access
    query_params.keys.each do |key|
      if documentData.key?(key)
        queryData[key] = documentData[key]
      end
    end
    return queryData
  end


  # Reset the TrueVault document with a default TrueVault document schema
  def reset_tv_document(vault_id, api_key)
    schema = self.get_document_schema
    schemaToJsonString = schema.to_json
    schemaToBase64 = Base64.encode64(schemaToJsonString)
    tvResponse = `curl https://api.truevault.com/v1/vaults/#{vault_id}/documents/#{self.documentID} \
    -u #{api_key}: \
    -X PUT \
    -d "document=#{schemaToBase64}"`

    # Parse and return a json hash of the TrueVault response
    tvResponseJSON = JSON.parse(tvResponse).with_indifferent_access
  end


  # Given the context requirements, gets only the most recent datapoints stored in TrueVault for each context.
  def get_latest_datapoints(vault_id, api_key, context_requirements)
    queryData = self.query_tv_document(vault_id, api_key, context_requirements)
    queryData.keys.each do |key|
      if queryData[key].class == Array and not queryData[key].empty?
        latestPoint = queryData[key][0]
        queryData[key].each do |value|
          if value["endDate"] > latestPoint["endDate"]
            latestPoint = value
          end
          queryData[key] = latestPoint
        end
      end
    end
    return queryData
  end


  def getGraphData(contextData)
    dataPointsArray = []
    contextData.keys.each do |dataType|
      contextData[dataType].each do |dataPoint|
        hash = {}
        hash["timestamp"] = dataPoint["endDate"]
        hash["steps"] = dataPoint["quantity"]
        dataPointsArray.push(hash)
      end
    end
    return dataPointsArray
  end
end
