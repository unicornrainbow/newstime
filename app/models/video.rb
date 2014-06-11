class Video
  include Mongoid::Document
  field :name, type: String

  include Mongoid::Paperclip
  has_mongoid_attached_file :video_file
  has_mongoid_attached_file :cover_image

  # Extract and set a cover image from the video source.
  def extract_cover!(offset=0.0)
    random_name = (0...8).map { (65 + rand(26)).chr }.join
    tmp_file = "tmp/#{random_name}.jpg"

    `ffmpeg -itsoffset -#{offset} -i '#{video_file.path}' -vframes 1 -an #{tmp_file}`

    # Attach output image as cover image
    File.open(tmp_file) do |f|
      self.cover_image = f
      save
    end
  end

end
