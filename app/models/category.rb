class Category < ApplicationRecord
	# проверка чтобы было введено либо ключ клиента либо компании, только одно из них
	# проверка, является выбранная категория для уровная расходом или доходом и относится к компнаии или клиету как созданная подкатегория
end