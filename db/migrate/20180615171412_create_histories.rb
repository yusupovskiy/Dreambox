class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.string :object_log
      t.integer :object_id
      t.string :type_history
      t.text :note
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end