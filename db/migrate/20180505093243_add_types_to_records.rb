class AddTypesToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :record_type, :integer, null: false
    add_column :records, :visit_type, :integer, null: false
  end
end
