class Affiliate < ApplicationRecord
  belongs_to :company

  validates :address, presence: true
end
