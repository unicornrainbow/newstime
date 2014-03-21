class VideoContentItem < ContentItem
  field :caption, type: String
  belongs_to :video


  def video_url
    video.video_file.url
  end
end
