class Publication
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :default_layout_name, type: String
  field :website_url, type: String
  field :store_url, type: String
  field :default_price, type: String

  has_many :editions, inverse_of: :publication
  belongs_to :organization

  def build_edition
    editions.build(edition_defaults)
  end

  def edition_defaults
    # Finagle some defaults
    highest_unititled = editions.where(name: /Edition No./).desc(:name).try(:first)
    unless highest_unititled
      default_name = "Edition No. 1"
    else
      increment = highest_unititled.name.match(/Edition No. (.*)/).try(:captures).first
      default_name = "Edition No. #{increment.to_i+1}"
    end

    slug = default_name.underscore.gsub(/[ _]/, '-')
    slug.gsub!(/\./, '')
    {
      name: default_name,
      page_title: default_name,
      publish_date: Date.today,
      layout_name: default_layout_name,
      store_link: generate_store_link(slug),
      fmt_price: default_price,
      volume_label: default_name
    }
  end

  def generate_store_link(slug)
    # TODO: Store url should accept a slug or have access to paramters and
    # functions for formmatting...
    "#{store_url}/#{slug}" # Kind of a hack for now.
  end

  def default_sections
    [
      { name: "Main",         path: "main.html",         sequence: 10,  letter: 'A', pages_attributes: [ { number: 1 } ] },
      { name: "Business",     path: "business.html",     sequence: 20,  letter: 'B', pages_attributes: [ { number: 1 } ] },
      { name: "Sports",       path: "sports.html",       sequence: 30,  letter: 'S', pages_attributes: [ { number: 1 } ] },
      { name: "Comics",       path: "comics.html",       sequence: 40,  letter: 'C', pages_attributes: [ { number: 1 } ] },
      { name: "Bay Area",     path: "bay-area.html",     sequence: 50,  letter: 'L', pages_attributes: [ { number: 1 } ] },
      { name: "World/Nation", path: "world-nation.html", sequence: 60,  letter: 'W', pages_attributes: [ { number: 1 } ] }
    ]
  end

end
