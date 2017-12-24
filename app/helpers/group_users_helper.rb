module GroupUsersHelper
  include RequestValidation

  def group_users_role_checking(action_name)
    case action_name
    when 'get_group_not_joined_users'
      get_group_not_joined_users_pre_validation

      get_users_by_filter
    when 'create'
      add_user_into_group_pre_validation

      add_user_into_group_process
    when 'destroy'
      group_user_destroy_pre_validation

      group_user_destroy_process
    end
  end

  def group_user_destroy_pre_validation
    allow_access?('delete_group_user')
  end

  def get_group_not_joined_users_pre_validation
    allow_access?('get_group_not_joined_users')
  end

  def add_user_into_group_pre_validation
    allow_access?('add_user_into_group')
  end

  def group_user_destroy_process
    group_user = GroupUser.eager_load(:group, :user).find_by(user_id: params[:id].to_i)
    group      = group_user.group
    user       = group_user.user

    if group_user.destroy
      if group.label == 'admin_group'
        user.update_attributes(type: 'Employee')
      end
      @status = {
        :code    => Settings.code.success,
        :message => "Xóa thành viên ra khỏi nhóm thành công"
      }
    else
      @status = {
        :code    => Settings.code.failure,
        :message => "Xóa thành viên ra khỏi nhóm không thành công"
      }
    end
  end

  def data_pre_validation
    params[:users].each do |user|
      if user[:role_level].blank? or
         not GroupUser.role_levels.values.include?(user[:role_level])

        raise APIError::Common::BadRequest
      end
    end
  end

  def add_user_into_group_process
    data_pre_validation

    root  = Group.find_by(label: 'company_group')
    group = Group.find_by(id: params[:group_id])
    raise APIError::Common::BadRequest unless group.is_or_is_descendant_of?(root)

    if group.label == 'admin_group'
      User.where(id: params[:users].map { |e| e[:id] }).update_all(type: 'Admin')
    end

    GroupUser.bulk_insert do |worker|
      params[:users].each do |user|
        worker.add(
          :group_id   => group.id,
          :user_id    => user[:id],
          :role_level => user[:role_level],
          :regency    => Settings.regency[user[:role_level]]
        )
      end
    end

    @status = {
      :code    => Settings.code.success,
      :message => "Thành công"
    }
  end

  def get_users_by_filter
    @filter = JSON.parse(params[:filter])
    type    = @filter["type"].present? ? @filter["type"] : ["Admin", "Employee"]

    if @filter["group_id"].present?
      sql_joined_user = User.select(:id)
                            .joins(group_users: :group)
                            .where(groups: {id: @filter["group_id"]}).to_sql
      if @filter["all"].present?
        @users =  User.select(:id, :name, :email, :phone, :type, :gender)
                      .where(type: type)
                      .search(name_or_email_or_phone_cont: @filter["keyword"], gender_eq: @filter["gender"])
                      .result
                      .where.not("id IN (#{sql_joined_user})")
      else
        @users =  User.select(:id, :name, :email, :phone, :type, :gender)
                      .where(type: type)
                      .search(name_or_email_or_phone_cont: @filter["keyword"], gender_eq: @filter["gender"])
                      .result
                      .where.not("id IN (#{sql_joined_user})")
                      .paginate(page: @filter["page"], per_page: @filter["per_page"] || Settings.per_page)
      end
    else
      if @filter["all"].present?
        @users =  User.select(:id, :name, :email, :phone, :type, :gender)
                      .where(type: type)
                      .search(name_or_email_or_phone_cont: @filter["keyword"], gender_eq: @filter["gender"])
      else
        @users =  User.select(:id, :name, :email, :phone, :type, :gender)
                      .where(type: type)
                      .search(name_or_email_or_phone_cont: @filter["keyword"], gender_eq: @filter["gender"])
                      .result
                      .paginate(page: @filter["page"], per_page: @filter["per_page"] || Settings.per_page)
      end
    end
  end
end
