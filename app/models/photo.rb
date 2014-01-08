class Photo
  include Mongoid::Document
  field :name, type: String

  include Mongoid::Paperclip
  has_mongoid_attached_file :attachment
end
