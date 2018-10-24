class AddUserIdAndAffiliateIdToFinOperations < ActiveRecord::Migration[5.2]
  def change
    add_column :fin_operations, :user_id, :int
    add_column :fin_operations, :affiliate_id, :int
  end
end
