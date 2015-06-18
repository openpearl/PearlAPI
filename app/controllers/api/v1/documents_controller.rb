class Api::V1::DocumentsController < ApplicationController
  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    document = Document.find_by(id: params[:id])

    if not document.nil?
      var = document.update_document(params, document.documentID, @@tvVaultID, @@tvAdminAPI)
      render json: var
    end
  end

  private

    def document_params
      params.require(:document).permit(:documentID, :documentData)
    end
end
