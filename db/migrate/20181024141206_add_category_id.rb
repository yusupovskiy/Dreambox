class AddCategoryId < ActiveRecord::Migration[5.2]
  def change
    add_reference :records_services, :category, foreign_key: true, null: false
  end
end
