class Record < ApplicationRecord
  belongs_to :affiliate
  delegate :company, to: :affiliate, allow_nil: true
end
