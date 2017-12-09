class User < ApplicationRecord
  has_many :group_users
  has_many :groups, :through => :group_users
  enum status: [:active, :inactive]

  attr_accessor :group_id

  validates :username, uniqueness: true, allow_blank: true

  def serializable_hash options=nil
    super.merge(type: type) rescue super
  end

  class << self
    def get_user_list(params)
      return User.search(username_or_name_or_email_or_phone_cont: params[:keyword])
                 .result.order(:type)
                 .paginate :page => params[:page], :per_page => Settings.per_page
    end

    def get_user_with_group(query)
      return User.find_by query
                 # .joins(:groups)

    end

    def get_sample_users
      @users = User.find_by_sql(%Q|
              (select username, type from users where type = 'Admin' limit 1)
        union (select username, type from users where type = 'Employee' limit 1)
      |)

      return @users
    end
  end
end
