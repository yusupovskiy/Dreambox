class AddRecordLimitAndTimeLimitAndNote < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :record_limit, :integer
    add_column :companies, :time_limit, :date
    add_column :companies, :note, :text
  end
end
