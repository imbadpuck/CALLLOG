class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  require 'jsonwebtoken'
  respond_to :json

  rescue_from APIError::Base do |e|
    key_error = e.class.name.split("::").drop(1).map(&:underscore)
    data      = nil
    if e.message.is_a?(Hash)
      error_code = e.message[:status]
      message    = e.message[:message]
      if e.message.has_key?(:data)
        data = e.message[:data]
      end
    else
      error_code = Settings.error_codes[key_error[0].to_sym][key_error[1].to_sym]
      message    = e.message
    end

    render json: {
      :code    => Settings.code.failure,
      :message => message
    }.merge!(data.present? ? {data: data} : {}) , :status => error_code
  end

  def get_current_user
    return unless session[:user]

    current_user_hash = {}
    if session[:user].class == Hash
      current_user_hash = session[:user]
    elsif session[:user].present?
      current_user_hash = session[:user].attributes
    end

    @current_user ||= User.new(current_user_hash)
  end

  def authenticate_request!
    token = request.headers['Authorization'].split(' ').last rescue nil
    payload = JsonWebToken.decode(token)
    if payload.nil? || !JsonWebToken.valid_payload(payload.first)
      return render json: {:message => "Bạn cần phải đăng nhập trước khi tiếp tục."}, status: 401
    end

    if session[:user].blank?
      session[:user] =  User.select("users.*", "groups.id as group_id")
                            .joins('LEFT JOIN group_users ON users.id = group_users.user_id')
                            .joins('LEFT JOIN groups ON groups.id = group_users.group_id')
                            .find_by_id payload.first['user_id']
    end

    get_current_user
    raise APIError::Client::Unauthorized unless @current_user
  end

  def load_user_authentication
    raise APIError::Common::BadRequest unless user_params[:username].present?
    query_hash = {}
    query_hash.merge!({username: user_params[:username]})

    @user = User.select("users.*", "groups.id as group_id")
                .joins('LEFT JOIN group_users ON users.id = group_users.user_id')
                .joins('LEFT JOIN groups ON groups.id = group_users.group_id')
                .find_by query_hash

    unless (@user && @user.valid_password?(user_params[:password]))
      return render json: {
        :message => "Tên đăng nhập hoặc mật khẩu không đúng"
      }, status: 200
    end
    if @user.active?
      return render json: {
        :message => "Tài khoản của bạn đã hủy kích hoạt. Vui lòng liên hệ quản trị viên."
      }, status: 200
    end
  end

  def check_Admin
    check_access_role(__method__.to_s)
  end

  private

  def check_access_role(method_name)
    method_name.slice!("check_")
    method_name = method_name.split("_and_")
    if @current_user.present?
      method_name.each do |m|
        return true if @current_user.type == m
      end
    end
    raise APIError::Client::Unauthorized.new
  end
end
