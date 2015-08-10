class Api::V1::GoalsController < ApplicationController
  before_action :get_document
  before_action :authenticate_user!


  # Controller actions for showing and updating user goals (such as being more active, losing weight, etc)
  def show
    if not @document.nil?
      tvDocument = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI)
      tvGoals = Goal.get_goals(tvDocument)

      render json: {
        message:  'Document was successfully retrieved.',
        data:   tvGoals
      },
        status: 200
    else
      render json: {
        message: 'Document does not exist!'
      },
        status: 500
    end
  end


  def update
    if not @document.nil?
      tvDocument = @document.read_tv_document(@@tvVaultID, @@tvAdminAPI)
      tvGoals = Goal.get_goals(tvDocument)
      updatedGoals = Goal.get_goal_updates(tvGoals, cleaned_params)
      @document.update_tv_document(@@tvVaultID, @@tvAdminAPI, updatedGoals)
      render json: {
        message:  'Document was successfully updated.'
      },
        status: 200
    else
      render json: {
        message: 'Document does not exist!'
      },
        status: 500
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
