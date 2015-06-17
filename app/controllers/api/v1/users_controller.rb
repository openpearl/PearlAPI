class Api::V1::UsersController < ApplicationController
  before_action :set_api_v1_user, only: [:show, :update, :destroy]

  # GET /api/v1/users
  # GET /api/v1/users.json
  def index
    @usersList = `curl https://api.truevault.com/v1/users \
    -X GET -u #{@@tvAdminAPI}:`
    render json: @usersList
  end

  # GET /api/v1/users/1
  # GET /api/v1/users/1.json
  def show #todo: Replace hardcoded user id in uri with dynamically generated id
    @user = `curl https://api.truevault.com/v1/users/07d4fdf5-fec3-44b5-a5e7-db228552533af \
    -X GET -u #{@@tvAdminAPI}:`
    render json: @user
  end

  # POST /api/v1/users
  # POST /api/v1/users.json
  def create
    @user = Api::V1::User.new(api_v1_user_params)
    if @user.valid?
      @tvResponseJSON = @user.create_tv_user(api_v1_user_params, @@tvAdminAPI)
      if !@tvResponseJSON["error"]
        @user.save
        render json: @user, status: :created, location: @user
      else
        render json: @tvResponseJSON["error"]
      end
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end    
  end
  
  

  # PATCH/PUT /api/v1/users/1
  # PATCH/PUT /api/v1/users/1.json
  # def update
    # @api_v1_user = Api::V1::User.find(params[:id])
# 
    # if @api_v1_user.update(api_v1_user_params)
      # head :no_content
    # else
      # render json: @api_v1_user.errors, status: :unprocessable_entity
    # end
  # end

  # DELETE /api/v1/users/1
  # DELETE /api/v1/users/1.json
  # def destroy
    # @api_v1_user.destroy
# 
    # head :no_content
  # end

  private

    def set_api_v1_user
      @api_v1_user = Api::V1::User.find_by(id: params[:id])
    end

    def api_v1_user_params
      params.require(:api_v1_user).permit(:email, :password, :password_confirmation, :name)
    end
end
