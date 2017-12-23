class Notification < ApplicationRecord
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  enum status: [:unseen, :seen]
end
