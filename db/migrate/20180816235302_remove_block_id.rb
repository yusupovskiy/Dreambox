class RemoveBlockId < ActiveRecord::Migration[5.2]
  def change
    remove_column :field_templates, :block_id, :integer
  end
end
