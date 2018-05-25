class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.date :start_at, null: false
      t.date :finish_at, null: false
      t.integer :visits, null: false
      t.boolean :is_active, null: false, default: true
      t.string :note
      t.float :price

      t.bigint :record_client_id, null: false
      t.index :record_client_id

      t.timestamps
    end

    add_foreign_key :subscriptions, :records_clients, column: :record_client_id
  end
end
