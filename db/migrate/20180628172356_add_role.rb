class AddRole < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :role, :integer
  end
end
