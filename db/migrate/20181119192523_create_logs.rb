class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.text :note, null: false
      t.belongs_to :user, foreign_key: true, null: false
      t.text :type_log, null: false

      t.timestamps
    end
  end
end
