class Api::V1::ConversationsController < ApplicationController
  before_action :pick_module
  before_action :get_document

  def converse
    convHash = @module.converse(context_params["cardID"])
      #Checks to see if the conversation node is a leaf by checking whether or not
      #it has children. If it does have children, then the conversation continues.
      #If not, then we know that the conversation has come to an end.
      if not convHash["childrenCardIDs"].nil? 
        
        # Filter out any invalid children 
        filteredCardIDs = []
        convHash["childrenCardIDs"].each do |childCardID|
          childCard = @module.converse(childCardID)
          if not childCard["filters"].nil?
            if @module.pass_filter?(childCard["filters"])
              filteredCardIDs.push(childCardID)
            end
          else
            filteredCardIDs.push(childCardID)
          end
        end


        #Gets the next conversation node corresponding to the first valid child of the current node.
        childMessage = @module.converse(filteredCardIDs[0])
        
        #Checks who the speaker for the next conversation node is.
        childSpeaker = childMessage["speaker"]
        

        #Instantiate a children array for keeping track of a node's children.
        childrenArray = []
        
        #If the speaker for the next conversation nodes is the client, then append all the
        #next conversation nodes to an array.
        if childSpeaker=="client"
          filteredCardIDs.each do |cardID|
            childrenArray.push(@module.converse(cardID))
          end  
        
        #If the speaker for the next conversation node is not the client, then we simply
        #choose a node from the children conversation nodes to proceed with in our conversation.
        #We also pick an AI message randomly to add variety to the conversation.
        else
          numberOfchildren = filteredCardIDs.length
          randomChild = Random.rand(numberOfchildren)
          cardID = filteredCardIDs[randomChild]
          childCard = @module.converse(cardID)

          if childCard["messages"].class == Array
            numberOfMessages = childCard["messages"].length
            randomMessage = Random.rand(numberOfMessages)
            childCard["messages"] = childCard["messages"][randomMessage]
          end
          
          childrenArray.push(childCard)
        end
        
        #Save the data about the children conversation nodes in the conversation hash under the 
        #key of "childrenCards".
        convHash["childrenCards"] = childrenArray
        
        #Renders a json of the conversation hash 
        render json: convHash
      else
        #Renders a null json since we are at a leaf node and there is no children.
        render json: convHash["childrenCardIDs"]
      end

  end


  # Get the context requirements for the module, and form a response json for the client to request that
  # information. For iOS, it returns a json response for requesting data from HealthKit.
  def getContextUpdateRequirements
    contextRequirements = @module.getContextRequirements.with_indifferent_access
    contextUpdateRequirements = {}
    defaultEndDate = Time.new(2000).to_s(:db)

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
        contextUpdateRequirements[key]["endDate"] = data[key]["endDate"]
      else
        contextUpdateRequirements[key]["endDate"] = defaultEndDate
      end
    end

    # Return the final hash which should include all the information that the client will need to retrieve the
    # context data for the module.
    render json: contextUpdateRequirements
  end


  # Input: Latest context data from the client to update TrueVault with
  # Updates Truevault, then initializes the module with the context data.
  def syncContext
    if not @document.nil?
      @document.update_tv_document(@@tvVaultID, @@tvAdminAPI, context_params)
      contextRequirements = @module.getContextRequirements.with_indifferent_access
      contextData = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI, contextRequirements)
      data = @module.initializeContext(contextData)
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




  private

  # Right now it is just picking move module by default. TODO: Make this smarter.
  def pick_module
    begin
      @module ||= PearlEngine::Modules::MoveModule.new
      @module.initializeConversation
    end
  end

  def get_document
    begin
      @document = current_user.document
    rescue
      @document = nil
    end
  end

  def context_params
    params.except(:format, :controller, :action)
  end
end
