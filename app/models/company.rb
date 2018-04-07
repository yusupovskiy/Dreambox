class Company < ApplicationRecord
  belongs_to :user
  has_many :clients
  has_many :affiliates, dependent: :destroy
  has_many :services, dependent: :destroy

  validates :name, presence: true
end
