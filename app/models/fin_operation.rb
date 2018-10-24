class FinOperation < ApplicationRecord
  # belongs_to :subscription
  
  enum operation_type: {payment_other: 0, payment_subscription: 1, payment_salaries: 2}  

  validates :amount, :operation_date, :description, :affiliate_id, presence: true
end
