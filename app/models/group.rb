class Group < ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :edition

  field    :page_id,        type: BSON::ObjectId
  field    :group_id,       type: BSON::ObjectId # If a sub group
  field    :top,            type: Integer
  field    :left,           type: Integer
  field    :width,          type: Integer
  field    :height,         type: Integer


  def content_items
    edition.content_items.where(group_id: id)
  end

  def groups
    edition.groups.where(group_id: id)
  end
end
