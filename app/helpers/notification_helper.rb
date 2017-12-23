module NotificationHelper
  def get_notifications
    @notifications = Notification.where(receiver_id: @current_user.id).order(created_at: :desc)
    @total_unseen  = @notifications.where(status: Notification.statuses[:unseen]).count
  end

  def update_status
    @notification = Notification.find_by(id: params[:id])

    if @notification and
       @notification.receiver_id == @current_user.id and
       @notification.status      == "unseen"

      @notification.update_attributes(status: Notification.statuses[:seen])

      @status = {
        :code    => Settings.code.success,
        :message => 'Thành công'
      } and return
    end
    byebug

    @status = {
      :code    => Settings.code.failure,
      :message => 'Thất bại'
    }
  end

  def create_notification(notify_type, ticket, user_list = [])
    case notify_type
    when 'update_ticket'
      noti_for_related_users(
        ticket, user_list, "Công việc ##{ticket.id} đã bị thay đổi nội dung bởi #{@current_user.name}"
      )

      noti_for_assigned_users(
        ticket, user_list, "Công việc ##{ticket.id} đã bị thay đổi nội dung bởi #{@current_user.name}"
      )

    when 'comment_in_ticket'
      noti_for_users_in_conversation(ticket)

    when 'related_user'
      noti_for_related_users(
        ticket, user_list, "Bạn được cho là liên quan đến công việc ##{ticket.id}"
      )
    when 'assign_user'
      noti_for_assigned_users(
        ticket, user_list, "Bạn đã được gán vào công việc ##{ticket.id}"
      )
    end
  end


  def noti_for_assigned_users(ticket, user_list = [], title = '')
    if user_list.length == 0
      user_list = ticket.assigned_users
    end

    Notification.bulk_insert do |worker|
      user_list.each do |u|
        worker.add(
          title: title,
          content: {ui_sref:
            "main.ticket_dashboard.show({" +
              "dashboard_label: 'assigned_request_dashboard'," +
              "status: #{ticket.status}," +
              "ticket_id: #{ticket.id}" +
            "})"
          },
          receiver_id: u.id,
          ticket: ticket.id
        )
      end
    end

    return user_list
  end

  def noti_for_related_users(ticket, user_list = [], title = '')
    if user_list.length == 0
      user_list = ticket.related_users
    end

    Notification.bulk_insert do |worker|
      user_list.each do |u|
        worker.add(
          title: title,
          content: {ui_sref:
            "main.ticket_dashboard.show({" +
              "dashboard_label: 'related_request_dashboard'," +
              "status: #{ticket.status}," +
              "ticket_id: #{ticket.id}" +
            "})"
          },
          receiver_id: u.id,
          ticket: ticket.id
        )
      end
    end

    return user_list
  end

  def noti_for_users_in_conversation(ticket)
    Notification.bulk_insert do |worker|
      if @current_user.id != ticket.creator_id
        worker.add(
          title: "#{@current_user.name} đã bình luận trong công việc ##{ticket.id} của bạn",
          content: {ui_sref:
            "main.ticket_dashboard.show({" +
              "dashboard_label: 'own_request_dashboard'," +
              "status: #{ticket.status}," +
              "ticket_id: #{ticket.id}" +
            "})"
          },
          receiver_id: ticket.creator.id,
          ticket: ticket.id
        )
      end

      ticket.ticket_assignments.each do |t_assignment|
        if t_assignment.user_type == 'performer'
          worker.add(
            title: "#{@current_user.name} đã bình luận trong công việc ##{ticket.id}",
            content: {ui_sref:
              "main.ticket_dashboard.show({" +
                "dashboard_label: 'assigned_request_dashboard'," +
                "status: #{ticket.status}," +
                "ticket_id: #{ticket.id}" +
              "})"
            },
            receiver_id: t_assignment.user_id,
            ticket: ticket.id
          )
        elsif t_assignment.user_type == 'people_involved'
          worker.add(
            title: "#{@current_user.name} đã bình luận trong công việc ##{ticket.id}",
            content: {ui_sref:
              "main.ticket_dashboard.show({" +
                "dashboard_label: 'related_request_dashboard'," +
                "status: #{ticket.status}," +
                "ticket_id: #{ticket.id}" +
              "})"
            },
            receiver_id: t_assignment.user_id,
            ticket: ticket.id
          )
        end
      end
    end
  end
end
