module TicketDashboardHelper
  include RequestValidation

  def dashboard_role_checking
    dashboard_pre_validation

    case params[:dashboard_label]
    when 'own_request_dashboard'
      @query = %Q|where creator_id = #{@current_user.id}|
    when 'related_request_dashboard'
      @query = %Q|inner join ticket_assignments on tickets.id = ticket_assignments.ticket_id
        where
          ticket_assignments.user_id = #{@current_user.id}
            and
          ticket_assignments.user_type = #{User.user_types[:people_involved]}
      |
    when 'assigned_request_dashboard'
      @query = %Q|inner join ticket_assignments on tickets.id = ticket_assignments.ticket_id
        where
          ticket_assignments.user_id = #{@current_user.id}
            and
          ticket_assignments.user_type = #{User.user_types[:performer]}
      |
    when 'team_dashboard'
      # @query =  %Q|inner join ticket_assignments on tickets.id = ticket_assignments.ticket_id
      #   where
      #     ticket_assignments.user_id = #{@current_user.id}
      #       and
      #     ticket_assignments.user_type = #{User.user_types[:performer]}
      # |
    end

    dashboard_loading
  end

  def dashboard_pre_validation
    unless ["own_request_dashboard", "related_request_dashboard",
            "assigned_request_dashboard", "team_dashboard"
           ].include?(params[:dashboard_label])


      raise APIError::Common::BadRequest.new
    end

    allow_access?(params[:dashboard_label])
  end

  def dashboard_loading

    result = Ticket.transaction do
      Ticket.connection.execute(%Q|
        set @all         = 0,
            @new_ticket  = 0,
            @inprogress  = 0,
            @resolved    = 0,
            @out_of_date = 0,
            @closed      = 0,
            @cancelled   = 0;
      |)

      Ticket.connection.execute(%Q|
        select  if (tickets.status = '#{Ticket.statuses[:new_ticket]}',
                  @new_ticket  := @new_ticket + 1,
                if (tickets.status = '#{Ticket.statuses[:inprogress]}',
                  @inprogress  := @inprogress + 1,
                if (tickets.status = '#{Ticket.statuses[:resolved]}',
                  @resolved    := @resolved + 1,
                if (tickets.status = '#{Ticket.statuses[:out_of_date]}',
                  @out_of_date := @out_of_date + 1,
                if (tickets.status = '#{Ticket.statuses[:closed]}',
                  @closed      := @closed + 1,
                if (tickets.status = '#{Ticket.statuses[:cancelled]}',
                  @cancelled   := @cancelled + 1, 0)))))),
                (@all := @all + 1)
        from tickets #{@query};
      |)

      Ticket.connection.execute(%Q|
        select  @all, @new_ticket, @inprogress, @resolved, @out_of_date, @closed, @cancelled;
      |)
    end

    result = RawSql.convert_result_to_hash(result)[0]

    @all         = result[:@all]
    @new_ticket  = result[:@new_ticket]
    @inprogress  = result[:@inprogress]
    @resolved    = result[:@resolved]
    @out_of_date = result[:@out_of_date]
    @closed      = result[:@closed]
    @cancelled   = result[:@cancelled]
  end
end
