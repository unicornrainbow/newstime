class VideoContentItem < ContentItem
  field :caption, type: String
  belongs_to :video

  def video_url
    video.video_file.url
    #"videos/#{video.name}/#{File.extname(video.attachment.path)}"
  end

  def cover_image_url
    video.cover_image.url
  end
end
