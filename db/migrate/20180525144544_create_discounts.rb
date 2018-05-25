class CreateDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :discounts do |t|
      t.date :start_at, null: false
      t.date :finish_at, null: false
      t.float :value, null: false
      t.string :note, null: false
      t.boolean :is_active, null: false, default: true

      t.bigint :record_client_id, null: false
      t.index :record_client_id

      t.timestamps
    end

    add_foreign_key :discounts, :records_clients, column: :record_client_id
  end
end
