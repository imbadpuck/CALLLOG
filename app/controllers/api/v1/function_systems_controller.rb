class Api::V1::FunctionSystemsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action -> { function_role_checking(action_name) }

  include FunctionSystemHelper

  def index
    render json: {
      :code    => Settings.code.success,
      :message => '',
      :data    => @functions
    }
  end

  def get_new_functions
    render json: {
      :code    => Settings.code.success,
      :message => '',
      :data    => {
        :functions     => @functions,
        :page          => params[:page],
        :per_page      => Settings.per_page,
        :total_entries => @functions.total_entries
      }
    }
  end
end
