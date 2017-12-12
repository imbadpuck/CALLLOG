class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  require 'jsonwebtoken'
  include ApplicationHelper

  respond_to :json

  rescue_from APIError::Base do |e|
    er_code, message, data = generate_error_code_and_msg(e)

    render json: {
      :code    => Settings.code.failure,
      :message => message
    }.merge!(data.present? ? {data: data} : {}) , :status => er_code
  end

  def get_current_user
    return unless session[:user]

    @current_user ||= User.new(get_current_user_in_session)
  end

  protected

  def authenticate_request!
    user_has_logged_in?

    user_session_assignment

    get_current_user
  end

  def load_user_authentication
    username_checking

    query_hash = generate_query_hash

    @user = User.get_user_group_function(query_hash)

    update_device_token
  end

  def check_Admin
    check_access_role(__method__.to_s)
  end

  def check_Company
    check_access_role(__method__.to_s)
  end

  def check_BuildingManager
    check_access_role(__method__.to_s)
  end

  def check_Cashier
    check_access_role(__method__.to_s)
  end

  def check_Technician
    check_access_role(__method__.to_s)
  end

  def check_Customer
    check_access_role(__method__.to_s)
  end
end
