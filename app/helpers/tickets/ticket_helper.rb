module Tickets::TicketHelper
  include RequestValidation
  include Tickets::TicketCreateHelper
  include Tickets::TicketUpdateHelper

  def ticket_role_checking(action_name)
    case action_name
    when 'index'
      dashboard_pre_validation

      generate_tickets_query

      get_tickets
    when 'create'
      create_ticket_pre_validation

      ticket_creating
    when 'get_single_ticket'
      get_single_ticket_pre_validation

      get_ticket
    when 'dashboard'
      dashboard_pre_validation

      generate_dashboard_query

      dashboard_loading
    when 'update'
      ticket_update_pre_validation

      ticket_update
    when 'search'
      dashboard_pre_validation

      search_tickets
    end
  end

  def get_single_ticket_pre_validation
    unless ["own_request_dashboard", "related_request_dashboard",
            "assigned_request_dashboard", "team_dashboard",
            "all_working_group_dashboard"
           ].include?(params[:dashboard_label])


      raise APIError::Common::BadRequest
    end

    allow_access?(params[:dashboard_label])
  end

  def get_ticket
    @ticket = Ticket.select('tickets.*', 'groups.name as group_name', 'groups.id as group_id')
                    .joins("left join ticket_assignments on tickets.id = ticket_assignments.ticket_id")
                    .joins("left join users on users.id = ticket_assignments.user_id")
                    .joins("left join groups on groups.id = ticket_assignments.group_id")
                    .find_by(id: params[:ticket_id].to_i)

    raise APIError::Common::NotFound if @ticket.blank?

    @creator            = @ticket.creator
    @related_users      = @ticket.related_users
    @assigned_users     = @ticket.assigned_users
    @ticket.attachments = eval(@ticket.attachments)

    @comments    = Comment.eager_load(:user).where(ticket_id: @ticket.id)
    comment_temp = []
    @comments.each do |c|
      comment_temp << c.attributes.merge!({
        user: c.user.attributes.extract!('id', 'code', 'username', 'email')
      })
    end

    @comments = comment_temp
  end

  def create_ticket_pre_validation
    allow_access?('create_ticket')
  end

  def generate_tickets_query
    case params[:dashboard_label]
    when 'own_request_dashboard'
      @select_attributes = %Q|'tickets.*', 'users.name as creator_name', 'users.email as creator_email'|
      @query             = %Q|
        .joins("left join users on users.id = tickets.creator_id")
        .where(creator_id: #{@current_user.id})
      |
    when 'related_request_dashboard'
      @select_attributes = %Q|'tickets.*', 'users.name as creator_name', 'users.email as creator_email'|
      @query = %Q|
        .joins("left join users on users.id = tickets.creator_id")
        .joins(:ticket_assignments)
        .where("ticket_assignments.user_id = #{@current_user.id}
                and
                ticket_assignments.user_type = #{TicketAssignment.user_types[:people_involved]}")
        .distinct("tickets.id")
      |
    when 'assigned_request_dashboard'
      @select_attributes = %Q|'tickets.*', 'users.name as creator_name', 'users.email as creator_email'|
      @query = %Q|
        .joins("left join users on users.id = tickets.creator_id")
        .joins(:ticket_assignments)
        .where("ticket_assignments.user_id = #{@current_user.id}
                and
                ticket_assignments.user_type = #{TicketAssignment.user_types[:performer]}")
        .distinct("tickets.id")
      |
    when 'team_dashboard'
      @select_attributes = %Q|'tickets.*', 'users.name as creator_name', 'users.email as creator_email'|
      @query =  %Q|
        .joins("left join users on users.id = tickets.creator_id")
        .joins(:ticket_assignments)
        .where("ticket_assignments.group_id = #{params[:group_id]}")
        .distinct("tickets.id")
      |
    when 'all_working_group_dashboard'
      @select_attributes = %Q|'tickets.*', 'users.name as creator_name', 'users.email as creator_email'|
      @query =  %Q|
        .joins("left join users on users.id = tickets.creator_id")
        .joins(:ticket_assignments)
        .where("ticket_assignments.group_id = #{params[:group_id]}")
        .distinct("tickets.id")
      |
    end
  end

  def get_tickets
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

  def search_tickets
    @query << %Q|
      .search(
        title_cont: params[:keyword],
        created_at_gteq: params[:created_at],
        closed_date_lteq: params[:closed_date])
      .result
    |

    get_tickets
  end
end
