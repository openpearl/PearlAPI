class Api::V1::DocumentsController < ApplicationController
  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  
  def update
    document = current_user.document

    if not document.nil?
      doc = document.update_document(document_params, document.documentID, @@tvVaultID, @@tvAdminAPI)
      render json: {
                      status: 'success',
                      data:   doc.as_json
                    }
    else
      render json: {
                      status: 'error',
                      message: 'Document does not exist!'
                    }
    end
  end

  private

    def document_params
      params.except(:format, :controller, :action)
    end
end
