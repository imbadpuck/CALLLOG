module UserFunctionHelper
  include RequestValidation

  def user_function_role_checking(action_name)
    @status = {
      :code    => Settings.code.failure,
      :message => 'Cập nhật chức năng không thành công'
    }

    case action_name
    when 'update'
      user_function_index_pre_validation

      update_user_functions
    end
  end

  def user_function_index_pre_validation
    allow_access?('manage_group')
  end

  def update_user_functions
    @function_ids = params[:functions]
    @function_ids.uniq

    case params[:label]
    when 'user'
      UserFunction.where(user_id: params[:id]).delete_all
      UserFunction.bulk_insert do |worker|
        @function_ids.each do |f_id|
          worker.add(
            :user_id            => params[:id],
            :function_system_id => f_id
          )
        end
      end

      @status = {
        :code    => Settings.code.success,
        :message => 'Cập nhật chức năng thành công'
      }
    when 'group'
      UserFunction.where(group_id: params[:id]).delete_all
      UserFunction.bulk_insert do |worker|
        @function_ids.each do |f_id|
          worker.add(
            :group_id           => params[:id],
            :function_system_id => f_id
          )
        end
      end

      @status = {
        :code    => Settings.code.success,
        :message => 'Cập nhật chức năng thành công'
      }
    end

  end
end
