class Edition
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :title, type: String
  field :path, type: String
  field :created_at, type: Time
  field :html, type: String     # The render html source markup
  field :layout_name, type: String
  field :publish_date, type: Date
  field :store_link, type: String
  field :fmt_price, type: String  # Formatted price string

  # A default option inherited by the sections when template name isn't set
  field :default_section_template_name, type: String

  has_many :sections, :order => :sequence.asc
  belongs_to :organization

  liquid_methods :title

  # TODO: Delete me if the above works.
  #def to_liquid
    #{ 'title' => title }
  #end
end
