module ClientsHelper
  def options_for_sexes
    Client.sexes.keys.map{|s| [t(s), s] }
  end
end
