class Api::V1::GoalsController < ApplicationController
  before_action :get_document
  before_action :get_goals
  before_action :authenticate_user!


  # Controller actions for showing and updating user goals (such as being more active, losing weight, etc)
  def show
    if not @document.nil?
      tvDocument = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI)
      goalsData = @goal.get_goals(tvDocument)

      render json: {
        status: 'success',
        message:  'Document was successfully retrieved.',
        data:   goalsData
      }
    else
      render json: {
        status: 'error',
        message: 'Document does not exist!'
      }
    end
  end

  def update
    if not @document.nil?
        @document.update_tv_document(@@tvVaultID, @@tvAdminAPI,document_params)
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


  private

  def get_document
    begin
      @document ||= current_user.document
    rescue
      @document = nil
    end
  end


  def get_goals
      @goal ||= Goal.new
  end

  def settings_params
    params.except(:format, :controller, :action)
  end
end
