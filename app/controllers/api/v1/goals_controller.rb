class Api::V1::GoalsController < ApplicationController
  before_action :get_document
  before_action :authenticate_user!


  # Controller actions for showing and updating user goals (such as being more active, losing weight, etc)
  def show
    if not @document.nil?
      tvDocument = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI)
      tvGoals = Goal.get_goals(tvDocument)

      render json: {
        status: 'success',
        message:  'Document was successfully retrieved.',
        data:   tvGoals
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
      tvDocument = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI)
      tvGoals = Goal.get_goals(tvDocument)
      updatedGoals = Goal.get_goal_updates(tvGoals, cleaned_params)
      @document.update_tv_document(@@tvVaultID, @@tvAdminAPI, updatedGoals)
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

  def cleaned_params
    params.except(:format, :controller, :action)
  end
end
