class VideoContentItem < ContentItem
  field :caption, type: String
  belongs_to :video

  def video_url
    # Note: Edition relative
    video.video_url
  end

  def cover_image_url
    video.cover_image_url
  end
end
