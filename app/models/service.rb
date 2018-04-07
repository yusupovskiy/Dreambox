class Service < ApplicationRecord
  belongs_to :company

  validates :name, :company, presence: true
end
