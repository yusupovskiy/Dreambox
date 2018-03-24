class Client < ApplicationRecord
  belongs_to :company
  has_one :user

  validates :first_name, :last_name, length: {minimum: 3}
end
