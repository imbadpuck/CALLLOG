module SessionHelper
  def init_data
    session[:user] = @user
    @auth_token    = JsonWebToken.encode(user_id: @user.id)
  end
end
