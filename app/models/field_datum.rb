class FieldDatum < ApplicationRecord
  belongs_to :client
  validates :value, :field_id, :object_id, presence: true
end
