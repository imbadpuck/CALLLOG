class FunctionSystem < ApplicationRecord
  belongs_to :user
  has_many :user_functions

  acts_as_nested_set
  enum status: [:active, :inactive]
end
