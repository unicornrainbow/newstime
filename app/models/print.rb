class Print
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :edition
end
