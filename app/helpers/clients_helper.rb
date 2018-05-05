module ClientsHelper
  def options_for_sexes
    options_for(Client.sexes, 'sex')
  end
end
