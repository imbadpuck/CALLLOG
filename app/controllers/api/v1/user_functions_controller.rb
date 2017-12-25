class Api::V1::UserFunctionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action -> { user_function_role_checking(action_name) }

  include UserFunctionHelper

  def update
    render json: @status
  end
end