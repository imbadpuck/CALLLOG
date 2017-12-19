class Api::V1::TicketsController < ApplicationController
  before_action :authenticate_request!
  before_action -> { ticket_role_checking(action_name) }
  skip_before_action :verify_authenticity_token
  respond_to :json

  include TicketHelper
  include TicketDashboardHelper

  def create
    render json: @status
  end

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
          :feedback    => @feedback,
          :closed      => @closed,
          :cancelled   => @cancelled
        }
      }
    }
  end

  def get_single_ticket
    render json: {
      :code    => Settings.code.success,
      :message => "Thành công",
      :data    => {
        :ticket         => @ticket,
        :comments       => @comments,
        :creator        => @creator,
        :related_users  => @related_users,
        :assigned_users => @assigned_users
      }
    }
  end

  def search
    render json: {
      :code    => Settings.code.success,
      :message => '',
      :data    => {
        :tickets       => @tickets,
        :page          => params[:page].to_i,
        :per_page      => Settings.per_page,
        :total_entries => @tickets.total_entries
      }
    }
  end
end
