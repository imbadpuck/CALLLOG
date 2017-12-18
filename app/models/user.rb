class User < ApplicationRecord
  has_many :group_users     , :dependent => :delete_all
  has_many :groups          , :through => :group_users
  has_many :ticket_assignments, :dependent => :delete_all
  has_many :ticket          , :through => :ticket_assignments
  has_many :user_functions  , :dependent => :delete_all
  has_many :function_systems, :through => :user_functions
  has_many :comments     , :dependent => :delete_all
  has_many :sub_comments , :dependent => :delete_all
  has_many :notifications, :dependent => :delete_all

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

    def get_user_group_function(query)
      function_systems = []
      groups           = []
      user             = User.eager_load(:function_systems, groups: [:function_systems])
                             .find_by query

      if user.present?
        function_systems = user.function_systems.map{|e| e.attributes}
        user.groups.each do |group|
          groups.concat(group.self_and_ancestors.to_a)
        end

        groups.uniq
      end

      groups.each do |group|
        function_systems.concat(group.function_systems)
      end

      return {
        "user"             => user.attributes,
        "groups"           => groups.map{|e| e.attributes},
        "function_systems" => function_systems
      }
    end
  end
end
