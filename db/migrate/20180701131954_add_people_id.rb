class AddPeopleId < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :people_id, :integer, foreign_key: true, default: nil
  end
end
