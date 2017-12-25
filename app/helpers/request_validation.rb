module RequestValidation

  def allow_access?(label)
    raise APIError::Common::BadRequest.new unless enable_function(label)
  end

  def enable_function(label)
    return false if session["info"].blank?

    current_function = FunctionSystem.find_by_label(label)

    session["info"]["function_systems"].each do |function|
      if function_is_valid?({
        :function => current_function,
        :label    => function["label"],
        :node     => {:lft => function["lft"], :rgt => function["rgt"]}})

        return true
      end
    end

    return false
  end

  def function_is_valid?(data)
    if data[:label] == data[:function].label or data[:label] == 'function_root' or
      data[:function].is_child_of?(data[:node])

      return true
    end

    return false
  end
end
