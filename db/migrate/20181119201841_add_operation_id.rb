class AddOperationId < ActiveRecord::Migration[5.2]
  def change
    add_reference :reminders, :operation, foreign_key: true
  end
end
