class Section
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :page_title, type: String
  field :path, type: String
  field :sequence, type: Integer
  field :letter, type: String

  field :template_name, type: String

  belongs_to :edition
  belongs_to :layout
  belongs_to :organization
  has_many   :pages, order: :number.asc
  field      :ordinal, type: Integer

  ## Methods

  def renumber_pages!
    # For each page, number pages.
    pages.asc(:number).each_with_index do |page, i|
      page.update_attribute(:number, i+1) if page.number != i+1
    end
  end

  def next_page_number
    pages.max(:number).to_i + 1
  end

end
