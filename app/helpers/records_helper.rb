module RecordsHelper
  def client_title_in_select(client)
    title = "#{client.last_name} #{client.first_name}"
    title += " #{client.patronymic}" if client.patronymic
    title += " (#{client.birthday})" if client.birthday
    title
  end
end
