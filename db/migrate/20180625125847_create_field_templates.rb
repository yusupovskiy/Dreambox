class CreateFieldTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :field_templates do |t|
      t.string :name
      t.integer :block_id, foreign_key: true, null: false
      t.string :field_type
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
