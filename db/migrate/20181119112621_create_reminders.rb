class CreateReminders < ActiveRecord::Migration[5.2]
  def change
    create_table :reminders do |t|
      t.text :note, null: false
      t.date :date, null: false
      t.float :debt
      t.boolean :completed, null: false, default: false
      t.belongs_to :client, foreign_key: true, null: false
      t.belongs_to :affiliate, foreign_key: true, null: false

      t.timestamps
    end
  end
end
