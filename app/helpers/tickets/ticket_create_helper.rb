module Tickets::TicketCreateHelper
  include NotificationHelper

  def ticket_creating
    params[:new_ticket] = JSON.parse(params[:new_ticket])

    init_variables

    create_ticket

    assign_ticket

    if @new_ticket.present?
      @status = {
        :code    => Settings.code.success,
        :message => "Thành công"
      }
    else
      @status = {
        :code    => Settings.code.failure,
        :message => "Thất bại"
      }
    end
  end

  def init_variables
    @new_ticket = {
      :title       => params[:new_ticket][:title],
      :content     => params[:new_ticket][:content],
      :priority    => params[:new_ticket][:priority],
      :creator_id  => @current_user.id
    }

    @new_ticket_assignments = {
      :group_id       => params[:new_ticket][:group_id],
      :assigned_users => params[:new_ticket][:assigned_users] || [],
      :related_users  => params[:new_ticket][:related_users] || []
    }

    [:begin_date, :deadline].each do |key|
      if params[:new_ticket].has_key?(key) &&
         params[:new_ticket][key].present?
        @new_ticket.merge!({"#{key}": params[:new_ticket][key]})
      end
    end

    @group = Group.eager_load(:group_users).find_by(id: @new_ticket_assignments[:group_id])

    group_checking

    assigned_users_checking

    related_users_checking
  end

  def group_checking
    raise APIError::Common::BadRequest if !@group.working_group?
  end

  def assigned_users_checking
    return if @new_ticket_assignments[:assigned_users].blank?

    User.where(id: @new_ticket_assignments[:assigned_users]).each do |user|
      if user.blank? or user.type == 'Admin'
        raise APIError::Common::BadRequest
      end
    end
  end

  def related_users_checking
    return if @new_ticket_assignments[:related_users].blank?

    User.where(id: @new_ticket_assignments[:related_users]).each do |user|
      if user.blank?
        raise APIError::Common::BadRequest
      end
    end
  end

  def create_ticket
    if params[:new_ticket][:assigned_users].present?
      @new_ticket.merge!({status: Ticket.statuses[:inprogress]})
    else
      @new_ticket.merge!({status: Ticket.statuses[:new_ticket]})
    end

    @new_ticket = Ticket.create(@new_ticket)

    if params[:attachments].present? and @new_ticket.present?
      dir = "#{Rails.root}/public/attachments/tickets/#{@new_ticket.id}/"
      @new_ticket.update_columns(
        attachments: save_files_with_token(dir, params[:attachments]).to_json
      )
    end
  end

  def assign_ticket
    if @new_ticket_assignments[:assigned_users].present?
      TicketAssignment.bulk_insert do |worker|
        @new_ticket_assignments[:assigned_users].uniq.each do |user_id|
          worker.add(
            :user_id   => user_id,
            :ticket_id => @new_ticket.id,
            :group_id  => @group.id,
            :user_type => TicketAssignment.user_types[:performer]
          )
        end
      end
    else
      max_role_level = @group.group_users.maximum(:role_level)
      max_role_level = GroupUser.role_levels[max_role_level]

      TicketAssignment.bulk_insert do |worker|
        GroupUser.where(role_level: max_role_level, group_id: @group.id).each do |group_user|
          worker.add(
            :user_id   => group_user.user_id,
            :ticket_id => @new_ticket.id,
            :group_id  => @group.id,
            :user_type => TicketAssignment.user_types[:performer]
          )
        end
      end
    end

    TicketAssignment.bulk_insert do |worker|
      @new_ticket_assignments[:related_users].uniq.each do |user_id|
        worker.add(
          :user_id   => user_id,
          :ticket_id => @new_ticket.id,
          :group_id  => @group.id,
          :user_type => TicketAssignment.user_types[:people_involved]
        )
      end
    end

    create_notification('related_user', @new_ticket)
    create_notification('assign_user', @new_ticket)
  end
end
