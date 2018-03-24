class RemoveUniquenessFromCompaniesUserId < ActiveRecord::Migration[5.1]
  # Now users can have multiple companies
  def up
    remove_index :companies, :user_id
    add_index :companies, :user_id, unique: false
  end
  def down
    remove_index :companies, :user_id
    add_index :companies, :user_id, unique: true
  end
end
