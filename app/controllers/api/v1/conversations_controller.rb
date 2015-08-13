class Api::V1::ConversationsController < ApplicationController
  before_action :authenticate_user!, :except => [:bar, :foo, :converse, :get_guest_token]
  before_action :get_userID
  before_action :pick_plugin
  before_action :get_document



  # Checks the sign in status of the user. If not authenticated, gives the client a random guest token
  # to use.
  def get_guest_token
    if current_user
      render json: {
        signed_in: true
      },
      status: 200
    else
      Rails.cache.write(@userID, @userID, expires_in: 30.minutes)
      render json: {
        signed_in: false,
        guest_token: @userID
      },
      status: 200
    end
  end


  # Returns a storyboard card at the cardID given if a plugin is loaded and initialized.
  def converse
    guest_token = cleaned_params["guest_token"]

    if not guest_token.nil?
      expected_token = Rails.cache.read(guest_token)
      if guest_token == expected_token
        @userID = guest_token
      else
        render :nothing => true, :status => 401
        return
      end
    elsif guest_token.nil? and not current_user
      render :nothing => true, :status => 401
      return
    end

    if not cleaned_params["cardBody"].nil?
      @plugin.cacheToPluginData(cleaned_params["cardBody"], @userID)
      @plugin.handleUserInput(cleaned_params["cardBody"], @userID)
    end

    card = @plugin.getCard(cleaned_params["cardID"], @userID)

    render json: card, status: 200
  end


  # Get the context requirements for the plugin, and form a response json for the client to request that
  # information. For iOS, it returns a json response for requesting data from HealthKit.
  def getContextUpdateRequirements
    contextRequirements = @plugin.getContextRequirements
    contextUpdateRequirements = {}
    defaultStartDate = Time.new(2000).to_i
    defaultEndDate = Time.now.to_i

    # Strip out any custom Pearl context requirements, since the client does not have any knowledge of them.
    contextRequirements.keys.each do |context|
      if not context.start_with?("PearlData")
        contextUpdateRequirements[context] = contextRequirements[context]
      end
    end

    # Retrieve the latest datapoints for each of the context update requirements from TrueVault
    data = @document.get_latest_datapoints(@@tvVaultID, @@tvAdminAPI, contextUpdateRequirements)

    # Fill in the missing endDate information in the contextUpdateRequirements hash with the end date from the
    # latest TrueVault datapoints. If the context data does not yet exist in TrueVault (perhaps being used for the
    # first time), then populate it with a default endDate from the year 2000.
    contextUpdateRequirements.keys.each do |key|
      if data.key?(key) and not data[key].nil?
        contextUpdateRequirements[key]["startDate"] = data[key]["endDate"]
      else
        contextUpdateRequirements[key]["startDate"] = defaultStartDate
      end
      contextUpdateRequirements[key]["endDate"] = defaultEndDate
    end

    # Return the final hash which should include all the information that the client will need to retrieve the
    # context data for the plugin.
    render json: contextUpdateRequirements, status: 200
  end


  # Input: Latest context data from the client to update TrueVault with
  # Updates Truevault, then initializes the plugin with the context data.
  def syncContext
    if not @document.nil?
      documentUpdates = @document.get_document_updates(@@tvVaultID, @@tvAdminAPI, cleaned_params)
      @document.update_tv_document(@@tvVaultID, @@tvAdminAPI, documentUpdates)
      contextRequirements = @plugin.getContextRequirements
      contextData = @document.query_tv_document(@@tvVaultID, @@tvAdminAPI, contextRequirements)
      @plugin.initializeContext(contextData, @userID)
      render json: {
        message: 'Successfully synced data. Conversation is ready to begin.'
      }, status: 200
    else
      render json: {
        message: 'Document does not exist!'
      }, status: 500
    end
  end

  # Returns neatly formatted context data for graphing
  def showGraphData
    if not @document.nil?
      contextRequirements = @plugin.getContextRequirements
      contextData = @document.query_tv_document(@@tvVaultID, @@tvAdminAPI, contextRequirements)
      dataPointsArray = @document.getGraphData(contextData)
      render json: {
        data: dataPointsArray
      }, status: 200
    else
      render json: {
        message: 'Document does not exist!'
      }, status: 500
    end
  end



  private


  def get_userID
    begin
      @userID = current_user.id
      # Since current user is not found, the user must not yet be authenticated, so generate a random guest
      # token for them to use.
    rescue
      @userID = SecureRandom.urlsafe_base64
    end
  end


  def pick_plugin
    @plugin ||= PearlEngine::PearlPlugin.choosePlugIn(@userID)
  end


  def get_document
    begin
      @document ||= current_user.document
    rescue
      @document = nil
    end
  end


  def cleaned_params
    params.except(:format, :controller, :action)
  end
end
