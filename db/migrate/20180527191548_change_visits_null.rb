class ChangeVisitsNull < ActiveRecord::Migration[5.2]
  def change
  	change_column_null :subscriptions, :visits, true
  end
end
