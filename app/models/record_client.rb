class RecordClient < ApplicationRecord
  self.table_name = 'records_clients'

  belongs_to :record
  belongs_to :client
end
