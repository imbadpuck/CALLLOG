class Api::V1::GroupsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action -> { group_role_checking(action_name) }
  respond_to :json

  include GroupHelper

  def index
    render json: {
      :code    => Settings.code.success,
      :message => 'Thành công',
      :data    => {
        :groups => @groups,
        :users  => @users
      }
    }
  end

  def create
    render json: @status
  end

  def destroy
    render json: @status
  end

  private
  def group_params
    params.require(:group).permit(:name, :content, :purpose, :parent_id)
  end
end
