# Type sets StoryTextContentItems for a edition/story pair.
class EditionStoryTypeSetter

  def initialize(edition, story)
    @edition = edition
    @story = story
  end

  # Typesets content items.
  def typeset!(force=false)
    # Unless force == true, typesetting should only occur if output is older
    # then inputs.

    # Inputs (Dependenyies:
    #   - Edition Media Module (Last Mod Time on Media Module
    #   - Media
    # Outputs: (Renderings) ContentItem#rendered_at
  end

  # Return story text content items for the edition/story
  def content_items
  end

end
