class AddSubscriptionSale < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :subscription_sale, :string, default: ""
  end
end
