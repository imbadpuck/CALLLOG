class GroupUser < ApplicationRecord
  belongs_to :user
  belongs_to :group

  enum role_level: {member: 1, sub_leader: 2, leader: 3}
end
