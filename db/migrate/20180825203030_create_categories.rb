class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :budget, null: false
      t.string :subject, null: false
      t.integer :level, null: false
      t.string :color, null: true, default: nil
      t.string :icon, null: true, default: nil
      t.references :user, foreign_key: true, default: nil
      t.references :company, foreign_key: true, default: nil

      t.timestamps
    end
  end
end
