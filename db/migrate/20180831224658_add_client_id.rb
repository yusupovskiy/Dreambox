class AddClientId < ActiveRecord::Migration[5.2]
  def change
    add_reference :operations, :client, foreign_key: true
  end
end
