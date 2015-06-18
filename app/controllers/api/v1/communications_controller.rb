class Api::V1::CommunicationsController < ApplicationController
  before_action :set_conversation
   
  def converse
    #Set up the entire hash of possible conversation nodes and paths for a Pearl Module
    #at a given point in a conversation marked by commID.
    convHash = @conversation.converse(params["commID"])
    
    #Checks to see if the conversation node is a leaf by checking whether or not
    #it has children. If it does have children, then the conversation continues.
    #If not, then we know that the conversation has come to an end.
    if !convHash["childrenCardIds"][0].nil? 
      #Gets the next conversation node corresponding to the first child of the current node.
      childMessage = @conversation.converse(convHash["childrenCardIds"][0])
      
      #Checks who the speaker for the next conversation node is.
      childSpeaker = childMessage["speaker"]
      
      #Gets the number of children conversation nodes belonging to current node
      numberOfchildren = convHash["childrenCardIds"].count
      
      #Instantiate a children array for keeping track of a node's children.
      childrenArray = Array.new
      
      #If the speaker for the next conversation nodes is the client, then append all the
      #next conversation nodes to an array.
      if childSpeaker=="client"
        numberOfchildren.times do |child|
          commID = convHash["childrenCardIds"][child]
          childrenArray.push(@conversation.converse(commID))
        end  
      
      #If the speaker for the next conversation node is not the client, then we simply
      #choose a node from the children conversation nodes to proceed with in our conversation.
      #Current, this is done randomly.
      #TODO: Make choosing the next conversation node more intelligent.
      else
        randomNum = Random.rand(numberOfchildren)
        commID = convHash["childrenCardIds"][randomNum]
        childrenArray.push(@conversation.converse(commID))
      end
      
      #Save the data about the children conversation nodes in the conversation hash under the 
      #key of "childrenCards".
      convHash["childrenCards"] = childrenArray
      
      #Renders a json of the conversation hash 
      render json: convHash
    else
      #Renders a null json since we are at a leaf node and there is no children.
      render json: convHash["childrenCardIds"][0]
    end
  end
  
  private
    #Initializes a hash of all possible conversation nodes and paths for a given module.
    def set_conversation
      @conversation = OpenpearlMove::Logic.new
    end
end
