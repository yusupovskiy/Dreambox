class CreateOperationLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :operation_logs do |t|
      t.belongs_to :operation, foreign_key: true, null: false
      t.belongs_to :log, foreign_key: true, null: false

      t.timestamps
    end
  end
end
