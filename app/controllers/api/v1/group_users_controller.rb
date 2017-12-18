class Api::V1::GroupUsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action -> { group_users_role_checking(action_name) }

  include GroupUsersHelper

  def get_group_not_joined_users
    render json: {
      :code    => Settings.code.success,
      :message => "Thành công",
      :data    => {
        :users         => @users,
        :page          => @filter["page"],
        :per_page      => Settings.per_page,
        :total_entries => @users.total_entries
      }
    }
  end

  def create
    render json: @status
  end

  def destroy
    render json: @status
  end
end
