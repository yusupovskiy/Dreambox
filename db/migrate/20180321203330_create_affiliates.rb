class CreateAffiliates < ActiveRecord::Migration[5.1]
  def change
    create_table :affiliates do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :phone_number
      t.string :email
      t.belongs_to :company, foreign_key: true, null: false #, on_delete: :cascade
    end
  end
end
