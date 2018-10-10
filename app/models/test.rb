class Test < ApplicationRecord
	self.table_name = "companies"
	self.where("id = ?", 28)
end