class Document < ActiveRecord::Base
  belongs_to :user
  SECONDS_IN_DAY = 24*60*60

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


  # Replaces the data in the TrueVault document belonging to the current user with the new data given(a JSON hash)
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


  # Takes a list of datapoints sorted into date buckets, and returns it as a hash of daily average 
  # datapoints for graphing. Days with no data are not taken into account.
  def getGraphData(contextData)
    datapointsHash = {}
    contextData.keys.each do |dataType|
      datapointsHash[dataType] = []
      sortedList = self.sortDatapointToBuckets(contextData[dataType])
      sortedList.each do |value|
        tempHash = {}
        tempHash[:timestamp] = value[:endTime]
        begin
          tempHash[:quantity] = value[:datapoints].sum / (value[:uniqueDays].length)
        # Catch dvivde by zero errors
        rescue
          tempHash[:quantity] = value[:datapoints].sum 
        end
        datapointsHash[dataType].push(tempHash)
      end
      # Make sure the datapoints are sorted in reverse chronological order(most recent first)
      datapointsHash[dataType] = datapointsHash[dataType].sort_by{ |datapoint| datapoint[:timestamp] }.reverse
    end
    return datapointsHash
  end


  # Sorts datapoints with start date, end date and quantity information into buckets which non-linearizes time.
  # Greater granularity is givne to datapoints that are more recent, with points going up to one year back.
  def sortDatapointToBuckets(dataPoints)
    bucketList = [
      oneDayAgoBucket = {
        startTime: 1.day.ago.beginning_of_day.to_i,
        endTime: 1.day.ago.end_of_day.to_i,
        datapoints: [],
        uniqueDays: []
      },
      twoDaysAgoBucket = {
        startTime: 2.days.ago.beginning_of_day.to_i,
        endTime: 2.days.ago.end_of_day.to_i,
        datapoints: [],
        uniqueDays: []
      },
      threeDaysAgoBucket = {
        startTime: 3.days.ago.beginning_of_day.to_i,
        endTime: 3.days.ago.end_of_day.to_i,
        datapoints: [],
        uniqueDays: []
      },
      fourDaysAgoBucket = {
        startTime: 4.days.ago.beginning_of_day.to_i,
        endTime: 4.days.ago.end_of_day.to_i,
        datapoints: [],
        uniqueDays: []
      },
      fiveDaysAgoBucket = {
        startTime: 5.days.ago.beginning_of_day.to_i,
        endTime: 5.days.ago.end_of_day.to_i,
        datapoints: [],
        uniqueDays: []
      },
      sixDaysAgoBucket = {
        startTime: 6.days.ago.beginning_of_day.to_i,
        endTime: 6.days.ago.end_of_day.to_i,
        datapoints: [],
        uniqueDays: []
      },
      sevenDaysAgoBucket = {
        startTime: 7.days.ago.beginning_of_day.to_i,
        endTime: 7.days.ago.end_of_day.to_i,
        datapoints: [],
        uniqueDays: []
      },
      twoWeeksAgoBucket = {
        startTime: 2.weeks.ago.beginning_of_day.to_i,
        endTime: 1.weeks.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      threeWeeksAgoBucket = {
        startTime: 3.weeks.ago.beginning_of_day.to_i,
        endTime: 2.weeks.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      fourWeeksAgoBucket = {
        startTime: 4.weeks.ago.beginning_of_day.to_i,
        endTime: 3.weeks.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      twoMonthsAgoBucket = {
        startTime: 2.months.ago.beginning_of_day.to_i,
        endTime: 4.weeks.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      threeMonthsAgoBucket = {
        startTime: 3.months.ago.beginning_of_day.to_i,
        endTime: 2.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      fourMonthsAgoBucket = {
        startTime: 4.months.ago.beginning_of_day.to_i,
        endTime: 3.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      fiveMonthsAgoBucket = {
        startTime: 5.months.ago.beginning_of_day.to_i,
        endTime: 4.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      sixMonthsAgoBucket = {
        startTime: 6.months.ago.beginning_of_day.to_i,
        endTime: 5.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      sevenMonthsAgoBucket = {
        startTime: 7.months.ago.beginning_of_day.to_i,
        endTime: 6.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      eightMonthsAgoBucket = {
        startTime: 8.months.ago.beginning_of_day.to_i,
        endTime: 7.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      nineMonthsAgoBucket = {
        startTime: 9.months.ago.beginning_of_day.to_i,
        endTime: 8.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      tenMonthsAgoBucket = {
        startTime: 10.months.ago.beginning_of_day.to_i,
        endTime: 9.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      elevenMonthsAgoBucket = {
        startTime: 11.months.ago.beginning_of_day.to_i,
        endTime: 10.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      },
      twelveMonthsAgoBucket = {
        startTime: 12.months.ago.beginning_of_day.to_i,
        endTime: 11.months.ago.beginning_of_day.to_i - 1,
        datapoints: [],
        uniqueDays: []
      }
    ]

    startOfToday= Time.now.getutc.beginning_of_day.to_i
    endOfToday= Time.now.getutc.end_of_day.to_i

    dataPoints.each do |point|
      point = point.with_indifferent_access
      bucketList.each do |bucket|
        if point["startDate"] >= bucket[:startTime] and point["endDate"] <= bucket[:endTime]
          bucket[:datapoints].push(point["quantity"])

          # Allows us to keep track of the number of unique dates that the data is sampled from, so that we 
          # can get an accurate daily average.
          date = (point["endDate"]/SECONDS_IN_DAY).floor
          bucket[:uniqueDays].push(date) unless bucket[:uniqueDays].include?(date)
        end
      end

      # All datapoints for today are plotted individually instead of getting compounded, so we put them in 
      # their own "buckets"
      if point["startDate"] >= startOfToday and point["endDate"] <= endOfToday
        tempHash = {}
        tempHash[:startTime] = point["startDate"]
        tempHash[:endTime] = point["endDate"]
        tempHash[:datapoints] = [point["quantity"]]
        bucketList.unshift(tempHash)
      end
    end
    return bucketList
  end

end
