class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  # before_action :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    # usersList = `curl https://api.truevault.com/v1/users \
    # -X GET -u #{@@tvAdminAPI}:`
    # render json: usersList

    
    render json: params["keys"]
  end
# 
  # # GET /users/1
  # # GET /users/1.json
  # def show #todo: Replace hardcoded user id in uri with dynamically generated id
    # user = `curl https://api.truevault.com/v1/users/3b600f07-fa22-4812-9aad-36b0c26748ee \
    # -X GET -u #{@@tvAdminAPI}:`
    # render json: user
  # end

  # POST /users
  # POST /users.json
  def create 
    render json: params["keys"][0]=="steps"
  end


  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  # def update
    # @user = User.find(params[:id])
# 
    # if @user.update(user_params)
      # head :no_content
    # else
      # render json: @user.errors, status: :unprocessable_entity
    # end
  # end

  # DELETE /users/1
  # DELETE /users/1.json
  # def destroy
    # @user.destroy
# 
    # head :no_content
  # end

  private

    def set_user
      @user = User.find_by(id: params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name)
    end
    
    def auth_hash
      request.env['omniauth.auth']
    end
end
