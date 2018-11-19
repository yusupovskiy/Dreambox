class Reminder < ApplicationRecord
  # has_many :clients

  validates :note, :date, :client_id, :affiliate_id, presence: true
end
