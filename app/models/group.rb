class Group < ApplicationRecord
  has_many :group_users
  has_many :users, through: :group_users
  has_many :user_functions
  has_many :function_systems, through: :user_functions
  acts_as_nested_set
end
