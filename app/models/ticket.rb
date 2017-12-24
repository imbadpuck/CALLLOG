class Ticket < ApplicationRecord
  has_many :ticket_assignments, :dependent => :delete_all
  has_many :notifications     , :dependent => :delete_all
  has_many :comments          , :dependent => :delete_all
  belongs_to :group
  belongs_to :creator, class_name: 'User' , foreign_key: 'creator_id'

  acts_as_nested_set

  enum status: [:new_ticket, :inprogress, :resolved, :feedback, :out_of_date, :closed, :cancelled]
  enum priority: [:low, :medium, :high, :imminent]
  enum rating: {satisfied: 1, unsatisfied: 2}

  def related_users
    return  User.joins("left join ticket_assignments on users.id = ticket_assignments.user_id")
                .joins("left join tickets on tickets.id = ticket_assignments.ticket_id")
                .where("ticket_assignments.user_type = #{TicketAssignment.user_types[:people_involved]}
                        and
                        tickets.id = #{self.id}")
  end

  def assigned_users
    return  User.joins("left join ticket_assignments on users.id = ticket_assignments.user_id")
                .joins("left join tickets on tickets.id = ticket_assignments.ticket_id")
                .where("ticket_assignments.user_type = #{TicketAssignment.user_types[:performer]}
                        and
                        tickets.id = #{self.id}")
  end
end
