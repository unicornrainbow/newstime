class VideoContentItem < ContentItem
  field :video_name, type: String
  field :caption, type: String

  belongs_to :video

  def video_url
    # Note: Edition relative
    video.try(:video_url)
  end

  def cover_image_url
    video.try(:cover_image_url)
  end
end
