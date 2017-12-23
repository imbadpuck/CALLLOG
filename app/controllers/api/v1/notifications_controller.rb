class Api::V1::NotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  respond_to :json

  include NotificationHelper

  def index
    get_notifications

    render json: {
      :code    => Settings.code.success,
      :message => '',
      :data    => {
        :notifications => @notifications,
        :total_unseen  => @total_unseen
      }
    }
  end

  def update
    update_status

    render json: @status
  end
end
