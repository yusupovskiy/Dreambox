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
end
