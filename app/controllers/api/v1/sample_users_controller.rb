class Api::V1::SampleUsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json

  include SampleUserHelper

  def index
    get_sample_users

    render json: {
      code: Settings.code.sucess,
      message: "Thành công",
      data: {
        :sample_admin                => @sample_admin,
        :sample_it_hanoi_leader      => @sample_it_hanoi_leader,
        :sample_it_danang_leader     => @sample_it_danang_leader,
        :sample_it_hanoi_sub_leader  => @sample_it_hanoi_sub_leader,
        :sample_it_danang_sub_leader => @sample_it_danang_sub_leader,
        :sample_it_hanoi_employee    => @sample_it_hanoi_employee,
        :sample_it_danang_employee   => @sample_it_danang_employee,
        :sample_member               => @sample_member,
      }
    }
  end
end

