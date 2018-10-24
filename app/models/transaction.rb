class Transaction < ApplicationRecord
  # belongs_to :company_transaction

  validates :amount, :date, :note, presence: true
end
