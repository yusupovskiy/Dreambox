class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :first_name,   null: false
      t.string :last_name,    null: false
      t.string :patronymic,   null: true
      t.date   :birthday,     null: true
      t.string :phone_number, null: true

      t.belongs_to :company, foreign_key: true, null: false
      t.belongs_to :user,    foreign_key: true, null: true

      t.timestamps
    end
  end
end
