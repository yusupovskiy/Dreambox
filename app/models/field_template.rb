class FieldTemplate < ApplicationRecord
  enum field_type: {text: 'text', date: 'date', number: 'number', datetime: 'datetime'}
  validates :name, :field_type, presence: true
end
