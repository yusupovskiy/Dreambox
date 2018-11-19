class Client < ApplicationRecord
  belongs_to :company
  # belongs_to :reminder
  has_one :user
  has_many :field_data
  accepts_nested_attributes_for :field_data
  # has_many :works, foreign_key: :people_id


  enum sex: [ :male, :female, :unknown ]
  validates :first_name, :last_name, length: {minimum: 3}
  
  module Role
    COMPANY_OWNER = 1
    CLIENT = 2
    STUFF = 4
  end
end
