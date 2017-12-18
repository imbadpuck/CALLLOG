module TicketHelper
  include RequestValidation
  include TicketCreateHelper

  def ticket_role_checking(action_name)
    case action_name
    when 'index'
      dashboard_pre_validation

      generate_tickets_query

      get_tickets
    when 'create'
      ticket_creating
    when 'dashboard'
      dashboard_pre_validation

      generate_dashboard_query

      dashboard_loading
    when 'search'
      dashboard_pre_validation

      search_tickets
    end
  end

  def create_ticket_pre_validation
    allow_access?('create_tickets')
  end

  def generate_tickets_query
    case params[:dashboard_label]
    when 'own_request_dashboard'
      @select_attributes = %Q|'tickets.*'|
      @query             = %Q|.where(creator_id: #{@current_user.id})|
    when 'related_request_dashboard'
      @select_attributes = %Q|'tickets.*'|
      @query = %Q|.joins(:ticket_assignments)
                  .where("ticket_assignments.user_id = #{@current_user.id}
                          and
                        ticket_assignments.user_type = #{TicketAssignment.user_types[:people_involved]}")
      |
    when 'assigned_request_dashboard'
      @query = %Q|.joins(:ticket_assignments)
                  .where("ticket_assignments.user_id = #{@current_user.id}
                          and
                        ticket_assignments.user_type = #{TicketAssignment.user_types[:performer]}")
      |
    when 'team_dashboard'
      # @query =  %Q|inner join ticket_assignments on tickets.id = ticket_assignments.ticket_id
      #   where
      #     ticket_assignments.user_id = #{@current_user.id}
      #       and
      #     ticket_assignments.user_type = #{TicketAssignment.user_types[:performer]}
      # |
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
