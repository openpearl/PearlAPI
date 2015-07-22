
# Place controller actions for handling user settings in this file
class Api::V1::SettingsController < ApplicationController
  before_action :get_document
  before_action :authenticate_user!



  # # Controller actions for showing and updating user goals (such as being more active, losing weight, etc)
  # def showGoals 
  #   render json: @goals
  # end

  # def updateGoals
  #   @goals.update(goal_params)
  #   render json: @goals
  # end


  private
    
    def get_document
      begin
        @document = current_user.document
      rescue 
        @document = nil
      end
    end
    
    def settings_params
      params.except(:format, :controller, :action)
    end
end
