class FunctionSystem < ApplicationRecord
  belongs_to :user
  has_many :user_functions, :dependent => :delete_all

  acts_as_nested_set
  enum status: [:active, :inactive]

  def is_parent_of?(node)
    lft = 0
    rgt = 0
    if node.class == Hash
      lft = node[:lft]
      rgt = node[:rgt]
    else
      lft = node.lft
      rgt = node.rgt
    end

    return true if self.lft < lft and self.rgt > rgt

    return false
  end

  def is_child_of?(node)
    return !is_parent_of?(node)
  end
end
