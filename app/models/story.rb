class Story
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :body, type: String
  field :author, type: String
  field :source, type: String
  field :word_count, type: Integer

  before_save :count_words

  def count_words
    self.word_count = body.split(' ').count
  end

  alias :name :title
end
