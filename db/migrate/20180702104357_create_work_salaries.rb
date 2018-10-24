class CreateWorkSalaries < ActiveRecord::Migration[5.2]
  def change
    create_table :work_salaries do |t|
      t.string :pay_status, default: 'fixed'
      t.float :pay_object, default: 0
      t.boolean :is_active, null: false, default: true

      t.integer :work_id, foreign_key: true, null: false
      t.belongs_to :record, foreign_key: true
      t.belongs_to :affiliate, foreign_key: true

      t.timestamps
    end
  end
end
