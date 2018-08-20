class FieldDatum < ApplicationRecord
  belongs_to :client
  # belongs_to :info_block

  # validates :value, :field_id, :object_id, presence: true
  validates :field_id, :object_id, presence: true
end
