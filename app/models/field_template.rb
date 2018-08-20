class FieldTemplate < ApplicationRecord
  # belongs_to :info_block
  
  enum field_type: {text: 'text', date: 'date', number: 'number', datetime: 'datetime'}
  validates :name, :field_type, presence: true
end
