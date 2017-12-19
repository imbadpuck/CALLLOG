class Api::V1::CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action -> { comment_role_checking(action_name) }
  respond_to :json

  include CommentHelper

  def create
    render json: @status
  end

  def destroy

  end
end
