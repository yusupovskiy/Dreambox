class Service < ApplicationRecord
  belongs_to :company
  # has_many :record_service
  # has_many :records, through: :record_service

  validates :name, :company, presence: true
end
