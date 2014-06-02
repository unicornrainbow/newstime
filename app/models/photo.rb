class Photo
  include Mongoid::Document
  field :name, type: String
  #field :dimensions, type: Array
  field :width, type: Integer
  field :height, type: Integer
  field :aspect_ratio, type: Float

  include Mongoid::Paperclip
  has_mongoid_attached_file :attachment,
    :styles => {
      :original => ['1920x1680>', :jpg],
      :small    => ['100x100#',   :jpg],
      :medium   => ['250x250',    :jpg],
      :large    => ['500x500>',   :jpg]
    }

  before_save :extract_dimensions

  # Helper method to determine whether or not an attachment is an image.
  # @note Use only if you have a generic asset-type model that can handle different file types.
  def image?
    attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
  end


  def edition_relative_url_path
    "images/#{name}#{File.extname(attachment.path)}"
  end

private

  # Retrieves dimensions for image assets
  # @note Do this after resize operations to account for auto-orientation.
  def extract_dimensions
    return unless image?
    tempfile = attachment.queued_for_write[:original]
    unless tempfile.nil?
      geometry = Paperclip::Geometry.from_file(tempfile)
      self.width, self.height = [geometry.width.to_i, geometry.height.to_i]
      self.aspect_ratio = width.to_f/height
    end
  end

end
