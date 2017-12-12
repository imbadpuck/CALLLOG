module UserHelper
  include RequestValidation

  def role_checking(action_name)
    case action_name
    when 'index'
      allow_access?("user_index")
    end
  end
end
