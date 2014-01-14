class Edition
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :path, type: String
  field :created_at, type: Time
  field :html, type: String     # The render html source markup

  has_many :sections
  belongs_to :organization

  def to_liquid
    { 'title' => title }
  end
end
