class Subscription < ApplicationRecord
  belongs_to :record_client

  validates :start_at, :finish_at, :record_client_id, presence: true
  validate :ensure_start_is_less_than_finish

  def ensure_start_is_less_than_finish
    if start_at and finish_at and start_at >= finish_at
      errors.add(:start_at, '#start_at date must be less than #finish_at')
    end
  end
end
