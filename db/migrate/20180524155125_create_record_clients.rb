class CreateRecordClients < ActiveRecord::Migration[5.2]
  def change
    create_table :records_clients do |t|
      t.boolean :is_active, null: false, default: true
      t.boolean :is_automatic, null: false
      t.boolean :is_dynamic, null: false

      t.belongs_to :record, foreign_key: true, null: false
      t.belongs_to :client, foreign_key: true, null: false

      t.timestamps
    end

    add_index :records_clients, [:record_id, :client_id], unique: true
  end
end
