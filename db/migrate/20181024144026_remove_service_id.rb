class RemoveServiceId < ActiveRecord::Migration[5.2]
  def change
    remove_column :records_services, :service_id, :integer
  end
end
