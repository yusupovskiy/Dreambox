class Affiliate < ApplicationRecord
  belongs_to :company

  validates :name, :address, presence: true
end
