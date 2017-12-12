module SessionHelper
  def init_data
    @auth_token = JsonWebToken.encode(user_id: session["info"]["user"]["id"])
  end
end
