class ContentRegion
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :organization
  belongs_to :page
end
