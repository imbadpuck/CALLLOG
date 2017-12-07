class Api::V1::SampleUsersController < ApplicationController
  skip_before_action  :verify_authenticity_token
  respond_to :json

  def index
    render json: {
      code: Settings.code.sucess,
      message: "Thành công",
      data: User.get_sample_users.as_json
    }
  end
end

