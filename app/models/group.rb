class Group < ApplicationRecord
  has_many :group_users
  has_many :users, through: :group_users
  acts_as_nested_set
end
