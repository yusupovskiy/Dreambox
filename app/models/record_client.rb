class RecordClient < ApplicationRecord
  self.table_name = 'records_clients'

  belongs_to :client
end
