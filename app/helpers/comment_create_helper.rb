module CommentCreateHelper
  include RequestValidation

  def create_comment_pre_validation
    params[:new_comment] = JSON.parse(params[:new_comment])

    unless ['comment_in_all_ticket', 'comment_in_own_ticket',
            'comment_in_ticket_in_working_group', 'comment_in_assigned_ticket'
           ].include?(params[:comment_function_label])

      raise APIError::Common::BadRequest
    end

    allow_access?(params[:comment_function_label])

    create_comment_options_checking
  end

  def create_comment_options_checking
    @ticket = Ticket.find_by_id(params[:new_comment][:ticket_id].to_i)

    case params[:comment_function_label]
    when 'comment_in_all_ticket'
    when 'comment_in_own_ticket'
      if @ticket.creator_id != @current_user.id
        raise APIError::Common::BadRequest
      end
    when 'comment_in_ticket_in_working_group'
      unless session['info']['groups'].map{|g| g.id}.include?(@ticket.group_id)
        raise APIError::Common::BadRequest
      end
    when 'comment_in_assigned_ticket'
      unless @ticket.assgined_users.map{|u| u.id}.include?(@current_user.id)
        raise APIError::Common::BadRequest
      end
    end
  end

  def create_comment_execution
    @new_comment = {
      :content   => params[:new_comment][:content],
      :note      => params[:new_comment][:note] || nil,
      :user_id   => @current_user.id,
      :ticket_id => @ticket.id
    }

    @new_comment = Comment.create(@new_comment)

    if params[:attachments].present? and @new_comment.present?
      dir = "#{Rails.root}/public/attachments/comments/#{@new_comment.id}/"
      @new_comment.update_columns(attachments: save_files_with_token(dir, params[:attachments]).to_json)
    end

    if @new_comment.present?
      @ticket.update_attributes(comment_count: @ticket.comment_count + 1)
      @status = {
        :code    => Settings.code.success,
        :message => "Thành công",
        :data    => @new_comment.attributes.merge({
          user: @current_user.attributes.extract!('id', 'code', 'name', 'email')
        })
      }
    else
      @status = {
        :code    => Settings.code.failure,
        :message => "Thất bại",
      }
    end
  end
end
