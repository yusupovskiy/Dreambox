class OperationLog < ApplicationRecord
  validates :operation_id, presence: true
end
