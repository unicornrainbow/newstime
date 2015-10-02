class VideoContentItem < ContentItem
  field :video_name, type: String
  field :caption, type: String
  field :aspect_ratio, type: Float

  belongs_to :video


  def video_url
    # Note: Edition relative
    video.try(:video_url)
  end

  def cover_image_url
    video.try(:cover_image_url)
  end

  def aspect_ratio
    Video.find_by(name: video_name).try(:aspect_ratio)
  end
end
