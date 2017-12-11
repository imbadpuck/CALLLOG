class UserFunction < ApplicationRecord
  belongs_to :group
  belongs_to :user
  belongs_to :function_system
end
