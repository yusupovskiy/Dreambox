class History < ApplicationRecord
  validates :object_log, :object_id, :type_history, :note, :user_id, presence: true
end
