module Tickets::TicketUpdateHelper
  include RequestValidation
  include NotificationHelper

  def ticket_update_pre_validation
    params[:ticket] = JSON.parse(params[:ticket])

    @updated_ticket = Ticket.find_by_id(params[:id])

    # update_function_identity
  end

  def ticket_update
    init_variables_for_updating

    update_ticket

    assign_ticket_for_updating

    if @updated_ticket
      @status = {
        :code    => Settings.code.success,
        :message => "Thành công"
      }

      create_notification('update_ticket', @updated_ticket)
    else
      @status = {
        :code    => Settings.code.failure,
        :message => "Thất bại"
      }
    end
  end

  # def create_comment_for_updating_ticket
  #   @new_comment = {tcket}
  #   if @updated_ticket_hash[:rating] != @updated_ticket.rating
  #     if @updated_ticket.creator_id != @current_user.id ||
  #        not Ticket.ratings.values.include?(@updated_ticket_hash[:rating])
  #       raise APIError::Common::BadRequest
  #     else
  #       @new_comment.merge!({rating: @updated_ticket_hash[:rating]})
  #     end
  #   end
  #   if @updated_ticket_hash[:status] != @updated_ticket.status
  #     if @updated_ticket.creator_id != @current_user.id ||
  #        not Ticket.ratings.values.include?(@updated_ticket_hash[:rating])
  #       raise APIError::Common::BadRequest
  #     else
  #       @new_comment.merge!({rating: @updated_ticket_hash[:rating]})
  #     end
  #   end
  #   if @updated_ticket_hash[:rating] != Ticket.statuses[@updated_ticket.status]
  #     @new_comment.merge!({rating: @updated_ticket_hash[:rating]})
  #   end
  # end

  def init_variables_for_updating
    @updated_ticket_hash = {
      :title       => params[:ticket][:title],
      :content     => params[:ticket][:content],
      :priority    => params[:ticket][:priority],
      :rating      => params[:ticket][:rating] || nil,
      :status      => Ticket.statuses[params[:ticket][:status]]
    }

    if params[:ticket][:status] == Ticket.statuses[:resolved]
      @updated_ticket_hash.merge!(resolved_at: Time.zone.now)
    elsif params[:ticket][:status] == Ticket.statuses[:closed]
      @updated_ticket_hash.merge!(closed_at: Time.zone.now)
    end

    @updated_ticket_assignments_hash = {
      :group_id       => params[:ticket][:group_id],
      :assigned_users => params[:ticket][:assigned_users] || [],
      :related_users  => params[:ticket][:related_users]  || []
    }

    [:begin_date, :deadline].each do |key|
      if params[:ticket].has_key?(key) &&
         params[:ticket][key].present?
        @updated_ticket_hash.merge!({"#{key}": params[:ticket][key]})
      end
    end

    @group = Group.eager_load(:group_users).find_by(
      id: @updated_ticket_assignments_hash[:group_id]
    )

    group_checking_for_updating

    assigned_users_checking_for_updating

    related_users_checking_for_updating
  end

  def group_checking_for_updating
    raise APIError::Common::BadRequest if !@group.working_group?
  end

  def assigned_users_checking_for_updating
    return if @updated_ticket_assignments_hash[:assigned_users].blank?

    User.where(id: @updated_ticket_assignments_hash[:assigned_users]).each do |user|
      if user.blank? or user.type == 'Admin'
        raise APIError::Common::BadRequest
      end
    end
  end

  def related_users_checking_for_updating
    return if @updated_ticket_assignments_hash[:related_users].blank?

    User.where(id: @updated_ticket_assignments_hash[:related_users]).each do |user|
      if user.blank?
        raise APIError::Common::BadRequest
      end
    end
  end

  def update_ticket
    # create_comment_for_updating_ticket

    @updated_ticket.update_attributes(@updated_ticket_hash)

    if params[:attachments].present? and @updated_ticket
      dir = "#{Rails.root}/public/attachments/tickets/#{@updated_ticket.id}/"
      @updated_ticket.update_columns(attachments: save_files_with_token(dir, params[:attachments]).to_json)
    end
  end

  def assign_ticket_for_updating
    @updated_ticket.ticket_assignments
                   .where(ticket_id:@updated_ticket.id, user_type: TicketAssignment.user_types[:performer])
                   .delete_all
    if @updated_ticket_assignments_hash[:assigned_users].present?

      TicketAssignment.bulk_insert do |worker|
        @updated_ticket_assignments_hash[:assigned_users].uniq.each do |user_id|
          worker.add(
            :user_id   => user_id,
            :ticket_id => @updated_ticket.id,
            :group_id  => @group.id,
            :user_type => TicketAssignment.user_types[:performer]
          )
        end
      end
    else
      max_role_level = @group.group_users.maximum(:role_level)
      max_role_level = GroupUser.role_levels[max_role_level]
      TicketAssignment.bulk_insert do |worker|
        @group.group_users.where(role_level: max_role_level).each do |group_user|
          worker.add(
            :user_id   => group_user.user_id,
            :ticket_id => @updated_ticket.id,
            :group_id  => @group.id,
            :user_type => TicketAssignment.user_types[:performer]
          )
        end
      end
    end

    @updated_ticket.ticket_assignments
                   .where(ticket_id:@updated_ticket.id, user_type: TicketAssignment.user_types[:people_involved])
                   .delete_all
    TicketAssignment.bulk_insert do |worker|
      @updated_ticket_assignments_hash[:related_users].uniq.each do |user_id|
        worker.add(
          :user_id   => user_id,
          :ticket_id => @updated_ticket.id,
          :group_id  => @group.id,
          :user_type => TicketAssignment.user_types[:people_involved]
        )
      end
    end
  end

  def update_function_identity
    @active_edit_labels      = []
    @allowed_attributes      = []
    @allowed_attributes_hash = {}

    if @updated_ticket.creator_id == @current_user.id
      @active_edit_labels << 'edit_own_ticket'
    end

    if enable_function('edit_all_ticket')
      @active_edit_labels << 'edit_all_ticket'
    end

    if enable_function('edit_ticket_in_working_group') and
      session['info']['groups'].map{|g| g['id']}.include?(@updated_ticket.group_id)

      @active_edit_labels << 'edit_ticket_in_working_group'
    end

    FunctionSystem.where(label: @active_edit_labels).each do |f|
      @allowed_attributes << f.extra_content['allowed_attributes']
    end

    generate_allowed_attributes_hash
  end

  def generate_allowed_attributes_hash
    @allowed_attributes.uniq!

    params[:ticket].each do |k, v|
      if not @allowed_attributes.include?(k)
        raise APIError::Common::BadRequest
      end
    end
  end
end
