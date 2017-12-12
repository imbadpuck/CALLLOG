module TicketHelper
  include RequestValidation

  def ticket_role_checking
    ticket_pre_validation

    case params[:dashboard_label]
    when 'own_request_dashboard'
      @select_attributes = %Q|'tickets.*'|
      @query             = %Q|.where(creator_id: #{@current_user.id})|
    when 'related_request_dashboard'
      @query = %Q|.joins(:ticket_assignments)
                  .where("ticket_assignments.user_id = #{@current_user.id}
                          and
                        ticket_assignments.user_type = #{User.user_types[:people_involved]}")
      |
    when 'assigned_request_dashboard'
      @query = %Q|.joins(:ticket_assignments)
                  .where("ticket_assignments.user_id = #{@current_user.id}
                          and
                        ticket_assignments.user_type = #{User.user_types[:performer]}")
      |
    when 'team_dashboard'
      # @query =  %Q|inner join ticket_assignments on tickets.id = ticket_assignments.ticket_id
      #   where
      #     ticket_assignments.user_id = #{@current_user.id}
      #       and
      #     ticket_assignments.user_type = #{User.user_types[:performer]}
      # |
    end

    getTickets
  end

  def ticket_pre_validation
    unless (["own_request_dashboard", "related_request_dashboard",
             "assigned_request_dashboard", "team_dashboard"
            ].include?(params[:dashboard_label]))


      raise APIError::Common::BadRequest.new
    end

    allow_access?(params[:dashboard_label])
  end

  def getTickets
    @status = params[:status] || "new_ticket"

    if @status == 'all'
      tickets_query = %Q|
        @tickets = Ticket.select(#{@select_attributes})#{@query}
                         .order(updated_at: :desc)
                         .paginate(page: params[:page], per_page: Settings.per_page)
      |
    else
      tickets_query = %Q|
        @tickets = Ticket.select(#{@select_attributes})#{@query}
                         .where(status: #{Ticket.statuses[params[:status].to_sym]})
                         .order(updated_at: :desc)
                         .paginate(page: params[:page], per_page: Settings.per_page)
      |
    end

    eval(tickets_query.gsub("\n",''))
  end

  def searchTicket
    return Ticket.select(
          "users.id as user_id", "users.name as user_name",
          "users.email as user_email", "tickets.*",
          "assigned_users.id as assigned_user_id",
          "assigned_users.name as assigned_user_name",
          "assigned_users.email as assigned_user_email")
          .eager_load(:user)
          .search(
            name_cont: params[:keyword],
            created_at_gteq: params[:created_at],
            closed_date_lteq: params[:closed_date])
          .result.order(updated_at: :desc)
          .paginate(page: params[:page], per_page: Settings.per_page)
  end
end
