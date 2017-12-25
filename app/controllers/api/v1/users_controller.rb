class Api::V1::UsersController < ApplicationController
  before_action :authenticate_request!
  before_action -> { user_role_checking(action_name) }
  skip_before_action :verify_authenticity_token, only: [:update, :create]
  respond_to :json

  include UserHelper

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

  def get_related_users
    render json: {
      :code    => Settings.code.success,
      :message => '',
      :data    => @users,
    }
  end

  def update

    params[:user] = JSON.parse(params[:user])
    @user = User.find_by_id(params[:id])

         @user.update_attributes(user_params)

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


  def create
    params[:user] = JSON.parse(params[:user])
    @user = User.new(user_params)
    if @user.save
      if params[:avatar].present?
        dir = "#{Rails.root}/public/attachments/avatars/#{@user.id}/"
        @user.update_columns(avatar: save_avatar_with_token(dir, params[:avatar]).to_json) 
      # do nothin
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


    private

    def user_params
          params.require(:user).permit(:username,:avatar,:name,:code,:status,:type,:birthdate,:gender,:phone, :email, :password)
    end

end
