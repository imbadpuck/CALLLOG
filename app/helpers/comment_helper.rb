module CommentHelper
  include RequestValidation
  include CommentCreateHelper

  def comment_role_checking(action_name)
    case action_name
    when 'create'
      create_comment_pre_validation

      create_comment_execution
    end
  end
end
