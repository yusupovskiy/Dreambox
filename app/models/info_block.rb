class InfoBlock < ApplicationRecord
  has_many :field_templates

  validates :name, presence: true
end
