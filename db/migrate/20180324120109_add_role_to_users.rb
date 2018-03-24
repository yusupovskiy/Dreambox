class AddRoleToUsers < ActiveRecord::Migration[5.1]
  def change
    # enum type
    add_column :users, :role, :integer, null: false, default: 0
  end
end
