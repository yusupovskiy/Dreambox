class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.string :name, null: false
      t.integer :abon_period
      t.integer :total_clients
      t.integer :total_visits
      t.date :finished_at
      t.belongs_to :affiliate, foreign_key: true, null: false

      t.timestamps
    end
  end
end
