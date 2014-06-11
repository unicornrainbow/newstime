class VideoContentItem < ContentItem
  field :caption, type: String
  belongs_to :video

  def video_url
    # Note: Edition relative
    "videos/#{video.name}#{File.extname(video.video_file.path)}"
  end

  def cover_image_url
    video.cover_image.url
  end
end
