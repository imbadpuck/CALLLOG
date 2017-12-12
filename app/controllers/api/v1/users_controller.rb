class Api::V1::UsersController < ApplicationController
  before_action :authenticate_request!
  skip_before_action :verify_authenticity_token
  before_action -> { role_checking(action_name) }

  include UserHelper

  respond_to :json

  def index
    @users = User.get_user_list(params)

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
end
