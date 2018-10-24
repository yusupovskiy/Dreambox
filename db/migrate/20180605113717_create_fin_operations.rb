class CreateFinOperations < ActiveRecord::Migration[5.2]
  def change
    create_table :fin_operations do |t|
      t.float :amount, null: false
      t.date :operation_date, null: false
      t.integer :operation_type
      t.integer :operation_object_id
      t.boolean :is_active, null: false, default: true
      t.text :description
      t.text :description_cancellation
 
      t.timestamps
    end
  end
end