class Group < ApplicationRecord
  has_many :group_users     , :dependent => :delete_all
  has_many :users           , through: :group_users
  has_many :user_functions  , :dependent => :delete_all
  has_many :function_systems, through: :user_functions
  has_one  :group
  acts_as_nested_set

  enum purpose: {classify: 2, working_group: 3}
end
