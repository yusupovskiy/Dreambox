class CreateFieldData < ActiveRecord::Migration[5.2]
  def change
    create_table :field_data do |t|
      t.string :value
      t.references :field, null: false
      t.references :client, null: false

      t.timestamps
    end
  end
end
