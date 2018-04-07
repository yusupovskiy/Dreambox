class CreateServices < ActiveRecord::Migration[5.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.boolean :is_active, null: false, default: true
      t.belongs_to :company, foreign_key: true, null: false

      t.timestamps
    end
  end
end
