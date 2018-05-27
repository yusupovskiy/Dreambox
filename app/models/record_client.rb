class RecordClient < ApplicationRecord
  self.table_name = 'records_clients'
  has_many :subscriptions

  belongs_to :record
  belongs_to :client
end
