class CreateWorks < ActiveRecord::Migration[5.2]
  def change
    create_table :works do |t|
      t.string :position_work, null: false
      t.float :fixed_rate, default: nil
      t.boolean :is_active, default: true
      t.belongs_to :affiliate, foreign_key: true

      t.bigint :people_id, null: false
      t.index :people_id

      t.timestamps
    end
    add_foreign_key :works, :clients, column: :people_id
  end
end
