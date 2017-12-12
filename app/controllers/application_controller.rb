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
    return if session["info"].blank?

    @current_user ||= User.new(session["info"]["user"])
  end

  protected

  def authenticate_request!
    user_has_logged_in?

    user_session_assignment

    get_current_user
  end

  def load_user_authentication
    username_checking

    session["info"] = User.get_user_group_function(generate_query_hash)
  end
end
