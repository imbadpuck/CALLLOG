class Api::V1::TicketsController < ApplicationController
  before_action :authenticate_request!
  before_action -> { ticket_role_checking }   , only: [:index]
  before_action -> { dashboard_role_checking }, only: [:dashboard]
  skip_before_action :verify_authenticity_token
  respond_to :json

  include TicketHelper
  include TicketDashboardHelper

  def index
    render json: {
      :code    => Settings.code.success,
      :message => "Thành công",
      :data    => {
        :tickets       => @tickets,
        :page          => params[:page].to_i,
        :per_page      => Settings.per_page,
        :total_entries => @tickets.total_entries
      }
    }
  end

  def dashboard
    render json: {
      :code    => Settings.code.success,
      :message => "Thành công",
      :data    => {
        :dashboard_label  => params[:dashboard_label],
        :statistical_data => {
          :all         => @all,
          :new_ticket  => @new_ticket,
          :inprogress  => @inprogress,
          :resolved    => @resolved,
          :out_of_date => @out_of_date,
          :closed      => @closed,
          :cancelled   => @cancelled
        }
      }
    }
  end

  def show
  end

  def update_status
  end

  def search
    render json: {
      :code    => Settings.code.success,
      :message => '',
      :data    => searchTicket
    }
  end
end
