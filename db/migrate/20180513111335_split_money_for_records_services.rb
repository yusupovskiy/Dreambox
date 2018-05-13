class SplitMoneyForRecordsServices < ActiveRecord::Migration[5.2]
  def change
  	rename_column :records_services, :money, :money_for_abon
  	change_column_null :records_services, :money_for_abon, true
  	add_column :records_services, :money_for_visit, :float
  end
end
