class FunctionSystem < ApplicationRecord
  enum status: [:active, :inactive]
end
