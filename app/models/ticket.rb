class Ticket < ApplicationRecord
  has_many :ticket_assignments
  belongs_to :user

  acts_as_nested_set
end
