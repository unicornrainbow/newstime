class Edition
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include TryHelper

  ## Attributes
  field :name,             type: String
  field :page_title,       type: String
  field :path,             type: String
  field :html,             type: String     # The render html source markup
  field :layout_name,      type: String
  field :publish_date,     type: Date
  field :store_link,       type: String
  field :price,            type: Float   # Formatted price string
  field :slug,             type: String


  field :page_color,       type: String
  field :ink_color,        type: String
  field :line_color,       type: String
  field :selection_color,  type: String
  #field :fmt_price,        type: String  # Formatted price string

  field :has_sections,     type: Boolean # True or false, depending if section bar should be
                                         # shown and sections, if any, rendered.

  def pricef
    return 0 unless price
    if price < 1.00
      "%.f¢" % (price.round(2)*100)
    else
      "$%.2f" % price.round(2)
    end
  end
  alias :fmt_price :pricef

  field :volume_label, type: String  # Formatted price string
  field :page_pixel_height, type: Integer, default: 1200  # Default pixel height of pages in edition

  # A default option inherited by the sections when template name isn't set
  field :default_section_template_name, type: String, default: "default"

  ## Relationships
  embeds_many  :sections
  embeds_many  :pages
  embeds_many  :content_items
  embeds_many  :groups
  embeds_many  :colors

  accepts_nested_attributes_for :sections
  accepts_nested_attributes_for :pages
  accepts_nested_attributes_for :content_items
  accepts_nested_attributes_for :groups
  accepts_nested_attributes_for :colors

  has_many :prints, :order => :created_at.desc

  has_one :masthead_artwork

  #belongs_to :organization
  belongs_to :user
  belongs_to :publication, inverse_of: :editions

  # Methods

  # Resolves and returns all images referenced in the edition.
  def resolve_photos
    # Edition > Sections > Pages > Content Regions > Photo Content Items > Photos

    photos = []
    sections.each do |section|
      section.pages.each do |page|
        photos += page.content_items.where(_type: 'PhotoContentItem').map(&:photo)
      end
    end

    photos.compact
  end


  def resolve_videos
    # Edition > Sections > Pages > Content Regions > Photo Content Items > Photos

    videos = []
    sections.each do |section|
      section.pages.each do |page|
        videos += page.content_items.where(_type: 'VideoContentItem').map do |content_item|
          Video.find_by(name: content_item.video_name)
        end
      end
    end
    videos.compact
  end

  def layout_module
    @layout_module ||= LayoutModule.new(layout_name)
  end

  def layout_module_root
    layout_module.root
  end

  def to_param
    slug || id.to_param
  end

  ## Liquid
  liquid_methods :title


  before_save do
    # HACK: Typeset content_items with changes
    content_items.where('_type' => 'TextAreaContentItem').each do |content_item|
      content_item.typeset!(layout_module) if content_item.changed?
    end
  end
end
