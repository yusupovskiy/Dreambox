class Record < ApplicationRecord
  belongs_to :affiliate
  delegate :company, to: :affiliate, allow_nil: true
  has_many :record_service
  has_many :services, through: :record_service

  # enum record_type: {grouping: 0, personal: 1}
  # enum visit_type: {one_time_visit: 0, reusable_visit: 1,
  #                   one_time_abon: 2, automatic_abon: 3, dynamic_abon: 4}

  enum record_type: {grouping: 0}
  enum visit_type: {one_time_abon: 0}
  # enum is_automatic: {not_automatic: 'not', upon_completion_automatic: 'calendar_automatic', calendar_automatic: 'calendar'}

  validates :name, :record_type, :visit_type, :created_at, :finished_at, :abon_period, :affiliate_id, :is_automatic, presence: true
end
