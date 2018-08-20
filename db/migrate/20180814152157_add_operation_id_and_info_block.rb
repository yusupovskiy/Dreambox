class AddOperationIdAndInfoBlock < ActiveRecord::Migration[5.2]
  def change
    add_reference :clients, :operation, foreign_key: true, null: false
    add_reference :subscriptions, :operation, foreign_key: true, null: false
    add_reference :records, :operation, foreign_key: true, null: false

    add_reference :field_templates, :info_block, foreign_key: true, null: false
  end
end
