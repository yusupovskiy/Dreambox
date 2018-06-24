class CreateSalaries < ActiveRecord::Migration[5.2]
  def change
    create_table :salaries do |t|
      t.date :start_at, null: false
      t.date :finish_at, null: false
      t.float :pay, null: false
      t.references :work, null: false
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
