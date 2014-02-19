class Page
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :section
  belongs_to :organization
  belongs_to :layout

  has_many :content_regions

  field      :name,    type: String
  field      :source,  type: String
  field      :number, type: Integer

  def pixel_height
    1200
  end

  def next_content_region_sequence
    content_regions.max(:sequence) || 0 + 1
  end

  def resequence_content_regions!
    content_regions.asc(:sequence).each_with_index do |content_region, i|
      content_region.update_attribute(:sequence, i+1) if content_region.sequence != i+1
    end
  end

  def grid_composition
  end

end
