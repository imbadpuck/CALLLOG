class Ticket < ApplicationRecord
  has_many :ticket_assignments
  belongs_to :user

  acts_as_nested_set

  enum status: [:new_ticket, :inprogress, :resolved, :out_of_date, :closed, :cancelled]
  enum priority: [:low, :medium, :high, :imminent]
end
