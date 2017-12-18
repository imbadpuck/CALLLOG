class Api::V1::UsersController < ApplicationController
  before_action :authenticate_request!
  before_action -> { user_role_checking(action_name) }
  skip_before_action :verify_authenticity_token
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
end
