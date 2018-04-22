module ApplicationHelper
  def s3_image(path)
    if path.nil?
      '/resources/no-image-available.png'
    else
      "#{S3_BUCKET.url}/#{path}"
    end
  end
end
