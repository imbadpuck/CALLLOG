module SessionHelper
# init data method
  def init_data
    @auth_token = JsonWebToken.encode(user_id: session["info"]["user"]["id"])
  end
end
