class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.belongs_to :user, foreign_key: true, index: {unique: true}, null: false
    end
  end
end
