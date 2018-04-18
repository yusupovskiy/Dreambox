class AddSexAndArchiveToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :archive, :boolean, null: false, default: false
    add_column :clients, :sex, :int

    reversible do |dir|
      dir.up do
        Client.update_all sex: :unknown
        change_column_null :clients, :sex, false
      end
    end
  end
end
