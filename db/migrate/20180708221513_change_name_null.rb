class ChangeNameNull < ActiveRecord::Migration[5.2]
  def change
  	change_column_null :affiliates, :name, true
  end
end
