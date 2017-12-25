module FunctionSystemHelper
  include RequestValidation

  def function_role_checking(action_name)
    case action_name
    when 'index'
      function_index_pre_validation

      get_functions_system
    when 'get_new_functions'
      function_index_pre_validation

      new_function_systems
    end
  end

  def new_function_systems
    get_functions_system

    if @functions.map{|f| f.id}.join(',').present?
      @new_functions =  FunctionSystem.where("function_systems.id not in (#{@functions.map{|f| f.id}.join(',')})")
                                  .paginate(page: params[:page], per_page: Settings.per_page)
    else
      @new_functions =  FunctionSystem.all.paginate(page: params[:page], per_page: Settings.per_page)
    end
  end

  def function_index_pre_validation
    allow_access?('manage_group')
  end

  def get_functions_system
    case params[:label]
    when 'user'
      @functions = FunctionSystem.joins(:user_functions)
                                 .where("user_functions.user_id = #{params[:id]}")
                                 .distinct.to_a
    when 'group'
      @functions = FunctionSystem.joins(:user_functions)
                                 .where("user_functions.group_id = #{params[:id]}")
                                 .distinct.to_a
    end

    # function_system_uniq
  end

  def function_system_uniq
    @functions.each_with_index do |f, index|
      @functions.each.with_index(index + 1) do |f_2, index_2|
        if f_2.id == f.id
          @functions.delete_at(index_2)
        elsif f_2.is_child_of?(f)
          @functions.delete_at(index_2)
        elsif f.is_child_of?(f_2)
          @functions.delete_at(index)
        end
      end
    end
  end
end
