class EditionRenderer

  def initialize(edition)
    @edition = edition
  end

  # Return rendered html
  def render
    @edition.source
  end

end
