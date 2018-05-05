class CreateRecordsServices < ActiveRecord::Migration[5.2]
  def change
    create_table :records_services, primary_key: %i[record_id service_id] do |t|
      t.belongs_to :record, foreign_key: true, null: false
      t.belongs_to :service, foreign_key: true, null: false
      t.float :money, null: false
      t.timestamps
    end
  end
end
