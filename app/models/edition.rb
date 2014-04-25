class Edition
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  ## Attributes
  field :name,         type: String
  field :page_title,        type: String
  field :path,         type: String
  field :created_at,   type: Time
  field :html,         type: String     # The render html source markup
  field :layout_name,  type: String
  field :publish_date, type: Date
  field :store_link,   type: String
  field :fmt_price,    type: String  # Formatted price string
  field :volume_label, type: String  # Formatted price string
  field :page_pixel_height, type: Integer, default: 1200  # Default pixel height of pages in edition

  # A default option inherited by the sections when template name isn't set
  field :default_section_template_name, type: String, default: "sections/default"

  has_mongoid_attached_file :compiled_editon  # The compiled version for signing and distribution.
  has_mongoid_attached_file :signature        # The signature to match the compiled version.

  ## Relationships
  has_many :sections, :order => :sequence.asc
  belongs_to :organization
  belongs_to :publication, inverse_of: :editions

  accepts_nested_attributes_for :sections

  state_machine :state, initial: :initial do
    event :print do
      transition :initial => :printing
    end

    event :print_complete do
      transition :printing => :printed
    end

    event :sign do
      transition :printed => :signed
    end

    event :publish do
      transition :signed => :published
    end

    event :reset do
      transition any => :initial
    end
  end

  ## Liquid
  liquid_methods :title
end
