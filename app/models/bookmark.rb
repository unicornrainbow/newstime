class Bookmark
  include MongoMapper::Document

  key :title,       String
  key :url,         String
  key :description, String
  key :created_at,  Time
end
