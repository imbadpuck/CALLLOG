class Api::V1::TicketDashboardController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action -> { role_checking(action_name) }
  before_action -> { dashboard_loading(action_name) }
  respond_to :json

  include TicketDashboardHelper

  def show
    render json: {
      :code    => Settings.code.success,
      :message => "Thành công",
      :data    => {
        :all         => @all,
        :new         => @new,
        :inprogress  => @inprogress,
        :resolved    => @resolved,
        :out_of_date => @out_of_date,
        :closed      => @closed,
        :cancelled   => @cancelled
      }
    }
  end
end
