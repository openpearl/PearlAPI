class Api::V1::ConversationsController < ApplicationController
  before_action :pick_plugin
  before_action :get_document
  before_action :authenticate_user!


  # For testing/debugging
  def test

  end

  # Returns a storyboard card at the cardID given if a plugin is loaded and initialized.
  def converse
    card = @plugin.getCard(context_params["cardID"], current_user.id)
    if card.nil?
      render json: {
        status: "error",
        message: 'End of conversation/no plugin loaded!'
      }
    else
      render json: card
    end
  end


  # Get the context requirements for the plugin, and form a response json for the client to request that
  # information. For iOS, it returns a json response for requesting data from HealthKit.
  def getContextUpdateRequirements
    contextRequirements = @plugin.getContextRequirements.with_indifferent_access
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
    render json: contextUpdateRequirements

  end


  # Input: Latest context data from the client to update TrueVault with
  # Updates Truevault, then initializes the plugin with the context data.
  def syncContext
    if not @document.nil?
      @document.update_tv_document(@@tvVaultID, @@tvAdminAPI, context_params)
      contextRequirements = @plugin.getContextRequirements.with_indifferent_access
      contextData = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI, contextRequirements)
      @plugin.initializeContext(contextData, current_user.id)
      render json: {
        status: 'success',
        message: 'Successfully synced data. Conversation is ready to begin.'
      }
    else
      render json: {
        status: 'error',
        message: 'Document does not exist!'
      }
    end
  end

  # Returns neatly formatted context data for graphing
  def showGraphData
    if not @document.nil?
      contextRequirements = @plugin.getContextRequirements.with_indifferent_access
      contextData = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI, contextRequirements).with_indifferent_access
      dataPointsArray = @document.getGraphData(contextData)
      render json: {
        status: 'success',
        data: dataPointsArray
      }
    else
      render json: {
        status: 'error',
        message: 'Document does not exist!'
      }
    end
  end


  private

  def pick_plugin
    @plugin ||= PearlEngine::PearlPlugin.choosePlugIn(current_user.id)
  end

  def get_document
    begin
      @document ||= current_user.document
    rescue
      @document = nil
    end
  end

  def context_params
    params.except(:format, :controller, :action)
  end
end
