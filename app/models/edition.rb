class Edition
  include Mongoid::Document
  include Mongoid::Timestamps

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

  # A default option inherited by the sections when template name isn't set
  field :default_section_template_name, type: String, default: "sections/default"

  include Mongoid::Paperclip
  has_mongoid_attached_file :compiled_editon  # The compiled version for signing and distribution.
  has_mongoid_attached_file :signature        # The signature to match the compiled version.

  ## Relationships
  has_many :sections, :order => :sequence.asc
  belongs_to :organization

  ## Liquid
  liquid_methods :title

end
