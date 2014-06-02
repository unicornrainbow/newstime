class Edition
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  ## Attributes
  field :name,         type: String
  field :page_title,   type: String
  field :path,         type: String
  field :created_at,   type: Time
  field :html,         type: String     # The render html source markup
  field :layout_name,  type: String
  field :publish_date, type: Date
  field :store_link,   type: String
  field :price,        type: Float   # Formatted price string
  #field :fmt_price,    type: String  # Formatted price string

  def pricef
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
  field :default_section_template_name, type: String, default: "sections/default"

  ## Relationships
  has_many :sections, :order => :sequence.asc
  has_many :prints, :order => :created_at.desc
  belongs_to :organization
  belongs_to :publication, inverse_of: :editions

  accepts_nested_attributes_for :sections


  # Methods

  # Resolves and returns all images referenced in the edition.
  def resolve_photos
    # Edition > Sections > Pages > Content Regions > Photo Content Items > Photos

    photos = []
    sections.each do |section|
      section.pages.each do |page|
        page.content_regions.each do |region|
          photos += region.content_items.where(_type: 'PhotoContentItem').map(&:photo)
        end
      end
    end
    photos


  end

  ## Liquid
  liquid_methods :title
end
