class Api::V1::UsersController < ApplicationController
  #Authenticate before any action
  before_action :authenticate_request!
  #Then
  before_action -> { user_role_checking(action_name) }
  #Skip it before action
  skip_before_action :verify_authenticity_token, only: [:update, :create]
  #Respond to json
  respond_to :json

  #Include lib contain helper method.
  include UserHelper

  #GET method for showing list users
  def index
    render json: {
      :code    => Settings.code.success,
      :message => '',
      :data    => {
        :user_list     => @users,
        :total_entries => @users.total_entries,
        :per_page      => Settings.per_page,
        :page          => params[:page]
      }
    }
  end
  #GET method for get related users
  def get_related_users
    render json: {
      :code    => Settings.code.success,
      :message => '',
      :data    => @users,
    }
  end

#PUT method for edit user.
  def update

    #Parse string data to JSON data
    params[:user] = JSON.parse(params[:user])
    #Search user by id
    @user = User.find_by_id(params[:id])
    #Edit user with new info
    @user.update_attributes(user_params)

    #Save avatar if it presents.
    if params[:avatar].present? and @user.present?

      dir = "#{Rails.root}/public/attachments/avatars/#{@user.id}/"
      @user.update_columns(avatar: save_avatar_with_token(dir, params[:avatar]).to_json)            
          render json: {
            :code    => Settings.code.success,
            :message => '',
            :data => User.find_by_id(params[:id])
        }
    else
          render json:  {
            :code    => Settings.code.failure,
            :message => "Thất bại"
      }
    end
  end

#POST method for creating new user. 
  def create
    params[:user] = JSON.parse(params[:user])
    @user = User.new(user_params)
    #If create a new user success, notice it
    if @user.save

      #Save avatar if it presents.
      if params[:avatar].present?
        dir = "#{Rails.root}/public/attachments/avatars/#{@user.id}/"
        @user.update_columns(avatar: save_avatar_with_token(dir, params[:avatar]).to_json)


      # Send email activation
          ActivationMailer.sample_email(@user).deliver
          render json:  {
              :code    => Settings.code.success,
              :message => "Thành công"
          }
        end
    else
          render json: {
            :code    => Settings.code.failure,
            :message => "Thất bại"
          }
    end
  end

#Input's parameter for POST/PUT method
    private

    def user_params
          params.require(:user).permit(:username,:avatar,:name,:code,:status,:type,:birthdate,:gender,:phone, :email, :password)
    end

end
