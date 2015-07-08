
# Place controller actions for handling user settings in this file
class Api::V1::SettingsController < ApplicationController
  before_action :set_goals
  before_action :authenticate_user!



  # Controller actions for showing and updating user goals (such as being more active, losing weight, etc)
  def showGoals 
    render json: @goals, :except=>  [:id, :user_id, :created_at, :updated_at]
  end

  def updateGoals
    @goals.update(goal_params)
    render json: @goals, :except=>  [:id, :user_id, :created_at, :updated_at]
  end


  private

      def set_goals
        begin
          @goals = current_user.goal
        rescue 
          @goals = nil
        end
      end
      
      def goal_params
        params.except(:format, :controller, :action)
      end
end
