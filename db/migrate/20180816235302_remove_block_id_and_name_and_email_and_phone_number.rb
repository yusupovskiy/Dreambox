class RemoveBlockIdAndNameAndEmailAndPhoneNumber < ActiveRecord::Migration[5.2]
  def change
    remove_column :field_templates, :block_id, :integer
    remove_column :affiliates, :name, :string
    remove_column :affiliates, :phone_number, :string
    remove_column :affiliates, :email, :string
  end
end
