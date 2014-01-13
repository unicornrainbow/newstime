class Edition
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :path, type: String
  field :source, type: String
  field :created_at, type: Time
  field :html, type: String     # The render html source markup
  field :title, type: String

  belongs_to :masthead

  def to_liquid
    { 'title' => title }
  end
end
