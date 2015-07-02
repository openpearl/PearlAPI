class Api::V1::DocumentsController < ApplicationController
  before_action :set_document
  
  
  def update
    if not @document.nil?
      modifiedDoc = @document.update_tv_document(document_params, @@tvVaultID, @@tvAdminAPI)
      render json: {
                      status: 'success',
                      data:   modifiedDoc.as_json
                    }
    else
      render json: {
                      status: 'error',
                      message: 'Document does not exist!'
                    }
    end
  end


  def reset
    if not @document.nil?
      tvResponseJSON = @document.reset_tv_document(@@tvVaultID, @@tvAdminAPI)
      if not tvResponseJSON["error"]
        render json: {
                        status: 'success',
                        data: {}
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
    
    def set_document
      begin
        @document = current_user.document
      rescue 
        @document = nil
      end
    end
    
    def document_params
      params.except(:format, :controller, :action)
    end
end
