class Api::V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :load_user_authentication

  include SessionHelper
  respond_to :json

  def create
    init_data

    render json: {
      :code    => Settings.code.success,
      :message => "Đăng nhập thành công",
      :data    => {
        :info  => session["info"],
        :token => @auth_token,
      }
    }, status: 200
  end

  private
  def user_params
    params.permit :username, :password
  end
end
