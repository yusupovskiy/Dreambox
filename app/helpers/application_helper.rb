module ApplicationHelper
  def s3_image(path)
    if path.nil?
      '/resources/no-image-available.png'
    else
      "#{S3_BUCKET.url}/#{path}"
    end
  end

  def options_for(field_hash, prefix = '')
    field_hash.keys.map{|s| [t(prefix.empty? ? s : "#{prefix}.#{s}"), s] }
  end

  def confirm_actions
    if Work.exists? people_id: @current_people.id, position_work: 'director' or Work.exists? people_id: @current_people.id, position_work: 'administrator'
      true
    else
      false
    end
  end
  def powers_director
    if Work.exists? people_id: @current_people.id, position_work: 'director'
      true
    else
      false
    end
  end
  def time_limit(date)
    time_limit = (date.year * 12 * 30) + (date.month * 30) + date.day
    today = (Date.today.year * 12 * 30) + (Date.today.month * 30) + Date.today.day
    day = time_limit - today
    if day < 0
      day = 0
    else
      day
    end 
  end



def totalDate(date, d, m, y)
  dateArray = date.split('-')

  if dateArray[1] == '01'
    dateArray[1] = 'января'
  elsif dateArray[1] == '02'
    dateArray[1] = 'февраля'
  elsif dateArray[1] == '03'
    dateArray[1] = 'марта'
  elsif dateArray[1] == '04'
    dateArray[1] = 'апреля'
  elsif dateArray[1] == '05'
    dateArray[1] = 'мая'
  elsif dateArray[1] == '06'
    dateArray[1] = 'июля'
  elsif dateArray[1] == '07'
    dateArray[1] = 'июня'
  elsif dateArray[1] == '08'
    dateArray[1] = 'августа'
  elsif dateArray[1] == '09'
    dateArray[1] = 'сентября'
  elsif dateArray[1] == '10'
    dateArray[1] = 'октября'
  elsif dateArray[1] == '11'
    dateArray[1] = 'ноября'
  elsif dateArray[1] == '12'
    dateArray[1] = 'декабря'
  end
  
  dDate = d ? dateArray[2] + ' ' : ''
  mDate = m ? dateArray[1] + ' ' : ''
  yDate = y ? dateArray[0] : ''

  newDate = dDate + mDate + yDate

  return newDate
end



end
