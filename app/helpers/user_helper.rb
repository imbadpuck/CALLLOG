module UserHelper
  include RequestValidation

  def user_role_checking(action_name)

    case action_name
    when 'index'
      allow_access?("user_index")

      user_index
    when 'get_related_users'
      allow_access?("create_ticket")

      related_users
    end
  end

  def user_index
    @users = User.get_user_list(params)
  end

  def related_users
    @users = []

    User.search(name_or_name_or_email_or_phone_cont: params[:keyword]).result.each do |user|
      @users << user.attributes.extract!('id', 'name', 'code', 'phone')
    end
  end
end
