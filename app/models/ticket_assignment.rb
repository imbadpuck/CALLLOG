class TicketAssignment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  enum user_type: [:performer, :people_involved]
end
