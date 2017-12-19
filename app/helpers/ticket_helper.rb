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
      create_ticket_pre_validation

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
    allow_access?('create_ticket')
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
                  .distinct("tickets.id")
      |
    when 'assigned_request_dashboard'
      @select_attributes = %Q|'tickets.*'|
      @query = %Q|.joins(:ticket_assignments)
                  .where("ticket_assignments.user_id = #{@current_user.id}
                          and
                          ticket_assignments.user_type = #{TicketAssignment.user_types[:performer]}")
                  .distinct("tickets.id")
      |
    when 'team_dashboard'
      @select_attributes = %Q|'tickets.*'|
      @query =  %Q|.joins(:ticket_assignments)
                   .where("ticket_assignments.group_id = #{params[:group_id]}")
                   .distinct("tickets.id")
      |
    when 'view_all_dashboard_of_working_group'
      @select_attributes = %Q|'tickets.*'|
      @query =  %Q|.joins(:ticket_assignments)
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
