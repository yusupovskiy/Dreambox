class Subscription < ApplicationRecord
  belongs_to :record_client
  #has_many :fin_operations, -> { where operation_type: :payment_subscription, is_active: true }, foreign_key: :operation_object_id

  validates :start_at, :finish_at, :record_client_id, presence: true
  validate :ensure_start_is_less_than_finish

  def ensure_start_is_less_than_finish
    if start_at and finish_at and start_at >= finish_at
      errors.add(:start_at, '#start_at date must be less than #finish_at')
    end
  end


  def self.price
    FinOperation.all
      .group("operation_object_id, operation_type")
      .select("operation_object_id, sum(amount) as amount")
      .order("operation_object_id")
  end
end
