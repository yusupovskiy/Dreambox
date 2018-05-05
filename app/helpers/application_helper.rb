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
end
