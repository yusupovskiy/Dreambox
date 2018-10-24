class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.float :amount, null: false
      t.date :date, null: false
      t.text :note
      t.boolean :is_active, null: false, default: true
      t.references :company_transaction, foreign_key: true, null: true
      t.references :user_transaction, foreign_key: true, null: true

      t.timestamps
    end
  end
end
