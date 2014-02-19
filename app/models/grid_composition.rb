class GridComposition
  def initialize(page)
    @page = page
  end

  def rows
    @rows ||= @page.content_regions.each_with_index.map do |content_region, i|
      GridCompositionRow.new(i+1, [content_region])
    end
  end

  def more_room?
    true
  end

  def next_row_sequence
    rows.count + 1
  end
end
