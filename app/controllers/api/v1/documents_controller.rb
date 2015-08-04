class Api::V1::DocumentsController < ApplicationController
  before_action :get_document
  before_action :authenticate_user!
  

  def read
    if not @document.nil?
      tvDocument = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI)
      render json: {
                      status: 'success',
                      message:  'Document was successfully retrieved.',
                      data:   tvDocument
                    }
    else
      render json: {
                      status: 'error',
                      message: 'Document does not exist!'
                    }
    end
  end
  
  # Queries the TrueVault document for the values associated with the keys as specified 
  # in document_params. 
  # Returns a json hash of all the key-value pairs found in the TrueVault document
  def query
    if not @document.nil?
      tvDocument = @document.query_tv_document(@@tvVaultID, @@tvAdminAPI, document_params)
      render json: {
                      status: 'success',
                      message:  'Document was successfully queried.',
                      data:   tvDocument
                    }
    else
      render json: {
                      status: 'error',
                      message: 'Document does not exist!'
                    }
    end
  end
  
  
  def update
    if document_params.keys.empty?
      render json: {
                      status: 'success',
                      message: 'No new data to add'
                    }
    else
      if not @document.nil?
        documentUpdates = @document.get_document_updates(@@tvVaultID, @@tvAdminAPI, document_params)
        tvResponse = @document.update_tv_document(@@tvVaultID, @@tvAdminAPI, documentUpdates)
        render json: {
                        status: 'success',
                        message:  'Document was successfully updated.'
                      }
      else
        render json: {
                        status: 'error',
                        message: 'Document does not exist!'
                      }
      end
    end
  end


  def reset
    if not @document.nil?
      tvResponseJSON = @document.reset_tv_document(@@tvVaultID, @@tvAdminAPI)
      if not tvResponseJSON["error"]
        render json: {
                        status: 'success',
                        message:  'Document was successfully reset.',
                      }
      else
        render json: {
                        status: 'error',
                        message: 'Could not reset document'
                      }
      end              
    else
      render json: {
                      status: 'error',
                      message: 'Document does not exist!'
                    }
    end
  end



  private
    
    def get_document
      begin
        @document ||= current_user.document
      rescue 
        @document = nil
      end
    end
    
    def document_params
      params.except(:format, :controller, :action)
    end
end
