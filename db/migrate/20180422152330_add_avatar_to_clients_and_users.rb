class AddAvatarToClientsAndUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :avatar, :string
  	add_column :clients, :avatar, :string
  end
end
