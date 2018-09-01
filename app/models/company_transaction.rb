class CompanyTransaction < ApplicationRecord
  # has_one :finance, foreign_key: "company_transaction_id", class_name: "Transaction"
  # # has_one :transaction
  # accepts_nested_attributes_for :finance

  validates :number_document, :affiliate_id, :category_id, presence: true
end
