class Group < ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :edition

  field    :page_id,        type: BSON::ObjectId
  field    :top,            type: Integer
  field    :left,           type: Integer
  field    :width,          type: Integer
  field    :height,         type: Integer
end
