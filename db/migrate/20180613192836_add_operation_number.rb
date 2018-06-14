class AddOperationNumber < ActiveRecord::Migration[5.2]
  def change
    add_column :fin_operations, :operation_number, :int
  end
end
