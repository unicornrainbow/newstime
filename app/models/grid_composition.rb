class GridComposition
  def initialize(page)
    @page = page
  end

  def rows
    @rows ||= @page.content_regions.map do |content_region|
      GridCompositionRow.new([content_region])
    end
  end

  def more_room?
    true
  end
end
