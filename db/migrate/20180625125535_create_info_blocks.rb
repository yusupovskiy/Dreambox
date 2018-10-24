class CreateInfoBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :info_blocks do |t|
      t.string :name
      t.string :model_object
      t.integer :company_id, foreign_key: true, null: false
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
