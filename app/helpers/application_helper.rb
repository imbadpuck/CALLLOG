module ApplicationHelper

  def generate_error_code_and_msg(e)
    key_e = e.class.name.split("::").drop(1).map(&:underscore)
    data  = nil

    if e.message.is_a?(Hash)
      er_code = e.message[:status]
      message = e.message[:message]
      if e.message.has_key?(:data)
        data = e.message[:data]
      end
    else
      er_code = Settings.error_codes[key_e[0].to_sym][key_e[1].to_sym]
      message = e.message
    end

    return er_code, message, data
  end

  def user_session_assignment
    if session["info"].blank?
      session["info"] = User.get_user_group_function({id: @payload.first['user_id']})
    end
  end

  def user_has_logged_in?
    @token   = request.headers['Authorization'].split(' ').last rescue nil
    @payload = JsonWebToken.decode(@token)
    if (@payload.nil? || !JsonWebToken.valid_payload(@payload.first))
      raise APIError::Client::Unauthorized.new({
        :message => {
          :status  => 401,
          :message => "Bạn cần phải đăng nhập trước khi tiếp tục.",
        }
      })
    end
  end

  def generate_query_hash
    return {username: user_params[:username]}
  end

  def username_checking
    raise APIError::Common::BadRequest if user_params[:username].blank?
  end

  def account_validation
    if not (@user.present? and @user.valid_password?(user_params[:password]))
      raise APIError::Client::Unauthorized.new({
        :message => {
          :status  => 401,
          :message => "Tên đăng nhập hoặc mật khẩu không đúng"
        }
      })
    end
    if @user.inactive?
      raise APIError::Client::Unauthorized.new({
        :message => {
          :status  => 401,
          :message => "Tên đăng nhập hoặc mật khẩu không đúng"
        }
      })
    end
  end

  def save_files_with_token dir, files
    file_name_list = [];
    begin
      files.each do |file|
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        extn      = File.extname file.original_filename
        name      = File.basename(file.original_filename, extn).gsub(/[^A-z0-9]/, "_")
        full_name = name + "_" + SecureRandom.hex(5) + extn
        path      = File.join(dir, full_name)
        file_name_list.push full_name
        File.open(path, "wb") { |f| f.write file.read }
      end
      return file_name_list
    rescue
      return []
    end
  end


  def save_avatar_with_token dir, file
    file_name = ' ';
    begin
      
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        extn      = File.extname file.original_filename
        name      = File.basename(file.original_filename, extn).gsub(/[^A-z0-9]/, "_")
        full_name = name + "_" + SecureRandom.hex(5) + extn
        path      = File.join(dir, full_name)
        file_name = full_name
        File.open(path, "wb") { |f| f.write file.read }

      return file_name
    rescue
      return []
    end
  end

  def check_access_role(method_name)
    method_name.slice!("check_")
    method_name = method_name.split("_and_")
    if @current_user.present?
      method_name.each do |m|
        return true if @current_user.type == m
      end
    end
    raise APIError::Client::Unauthorized.new
  end

  def bootstrap_class_for flash_type
    if ["error", "alert"].include? flash_type
      "alert-danger"
    else
      "alert-success"
    end
  end
end
