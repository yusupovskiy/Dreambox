module TransactionsHelper
  def nameMonth(month, ending)
    arrayNameMonth = ['', 'январь','февраль','март','апрель','май',
      'июнь','июль','август','сентябрь','октябрь','ноябрь','декабрь'];

    arrayNameMonth2 = ['', 'января','февраля','марта','апреля','мая',
      'июня','июля','августа','сентября','октября','ноября','декабря'];

    if ending == 1
      return arrayNameMonth[month.to_i]
    elsif ending == 2
      return arrayNameMonth2[month.to_i]
    end
  end
  def format_name(people)
    first_name = people.first_name
    last_name = people.last_name
    patronymic = people.patronymic

    if first_name.present?
      fio = first_name
    end
    if last_name.present?
      fio = fio + ' ' + last_name[0] + '.'
    end
    if patronymic.present?
      fio = fio + ' ' + patronymic[0] + '.'
    end

    return fio
  end
end
