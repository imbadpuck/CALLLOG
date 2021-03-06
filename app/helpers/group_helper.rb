module GroupHelper
  include RequestValidation

  def group_role_checking(action_name)

    case action_name
    when 'index'
      @groups = []
      group_index_pre_validation

      group_index
    when 'create'
      group_creation_pre_validation

      group_creation_process
    when 'update'
      group_update_pre_validation

      group_update_process
    when 'destroy'
      group_destroy_pre_validation

      group_destroy_process
    when 'assigned_user_in_group_preload'
      user_in_gr_preload_pre_validation

      assigned_user_in_own_gr_preload_execution
    end
  end

  def group_update_pre_validation
    allow_access?('edit_group')
  end

  def user_in_gr_preload_pre_validation
    allow_access?('assign_ticket_to_user_in_own_group')
  end

  def group_destroy_pre_validation
    allow_access?('delete_group')
  end

  def group_creation_pre_validation
    allow_access?('create_group')
  end

  def assigned_user_in_own_gr_preload_execution
    group = Group.find_by(id: params[:group_id])

    if group.blank? or Group.purposes[group.purpose].blank?
      raise APIError::Common::BadRequest
    end

    @users = []

    group.users.search(name_or_code_or_phone_cont: params[:keyword])
         .result.each do |user|
      if user.type != 'Admin'
        @users << user.attributes.extract!('id', 'name', 'code', 'phone')
      end
    end
  end

  def group_destroy_process
    group = Group.find_by(id: params[:id].to_i)
    if group.label == 'admin_group' or group.label == 'company_group'
      raise APIError::Common::BadRequest
    end

    if group.destroy
      @status = {
        :code    => Settings.code.success,
        :message => "Xóa nhóm thành công"
      }
    else
      @status = {
        :code    => Settings.code.failure,
        :message => "Xóa nhóm không thành công"
      }
    end
  end

  def group_update_process
    group = Group.find_by(id: params[:id])

    if group.present?
      group.update_attributes(
        content: params[:group][:content],
        name: params[:group][:name],
        purpose: params[:group][:purpose]
      )

      @status = {
        :code    => Settings.code.success,
        :message => "Sửa nhóm thành công"
      } and return
    end

     @status = {
        :code    => Settings.code.failure,
        :message => "Sửa nhóm không thành công"
      }
  end

  def group_creation_process
    root = Group.find_by(label: 'company_group')
    if group_params[:parent_id].present?
      parent_group = Group.find_by(id: group_params[:parent_id])
      raise APIError::Common::NotFound   unless parent_group.present?
      raise APIError::Common::BadRequest unless parent_group.is_or_is_descendant_of?(root)
    else
      parent_group = root
    end

    group = Group.new(group_params.merge(parent_id: parent_group.id))

    if group.save
      @status = {
        :code    => Settings.code.success,
        :message => "Thêm mới thành công"
      }
    else
      @status = {
        :code    => Settings.code.failure,
        :message => "Thêm mới thất bại"
      }
    end
  end

  def group_index
    case params[:function_label]
    when 'working_group_index'
      @groups = []
      Group.where(purpose: Group.purposes[:working_group]).each do |group|
        group_array = group.self_and_ancestors.to_a
        group_array.keep_if{|g| g.purpose == 'working_group' || g.label == 'company_group'}

        @groups.concat(group_array)
      end

      @groups.uniq!

    when 'get_tree_group'
      @groups = Group.find_by(label: 'company_group').self_and_descendants.to_a
      @users  = User.select(
                  "users.id as user_id", "users.name", "users.email", "users.birthdate",
                  "users.phone", "users.gender", "group_users.group_id",
                  "group_users.created_at as participate_date",
                  "group_users.regency")
                    .joins(:group_users)
                    .where(group_users: {group_id: @groups.map(&:id)})

      @groups.uniq!
      modify_data_before_render
    when 'get_group_not_joined_users'
    end
  end

  def modify_data_before_render
    groups_temp = []
    users_temp  = []

    if @groups.present?
      @groups.each do |group|
        group_temp               = group.attributes
        group_temp['created_at'] = group.created_at.strftime("%d/%m/%Y") rescue nil
        group_temp['updated_at'] = group.updated_at.strftime("%d/%m/%Y") rescue nil
        groups_temp             << group_temp
      end

      @groups = groups_temp
    end
    if @users.present?
      @users.each do |user|
        user_temp                     = user.attributes
        user_temp['gender']           = Settings.genders[user.gender]
        user_temp['participate_date'] = user.participate_date.strftime("%d/%m/%Y") rescue nil
        users_temp                   << user_temp
      end

      @users  = users_temp
    end
  end

  def group_index_pre_validation
    unless (["working_group_index", "get_tree_group"
            ].include?(params[:function_label]))

      raise APIError::Common::BadRequest.new
    end

    allow_access?(params[:function_label])
  end
end
