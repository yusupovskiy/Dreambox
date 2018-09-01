class CreateCompanyTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :company_transactions do |t|
      t.integer :number_document, null: false
      t.references :affiliate, foreign_key: true, null: false
      t.references :operation, foreign_key: true, null: true
      t.references :category, foreign_key: true, null: false

      t.timestamps
    end
  end
end
