# Type sets StoryTextContentItems for a edition/story pair.

require "net/http"
require "uri"

class EditionStoryTypeSetter
  LINEBREAK_SERVICE_URL = URI.parse(ENV['LINEBREAK_SERVICE_URL'])

  attr_reader :edition, :story

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
    @content_items ||= begin
      items = story.story_text_content_items.to_a

      # Reject, unless for the same edition
      items.select! do |content_item|
        content_item.edition.id == edition.id
      end

      # Order them based on Section Sequence -> Page Number -> Content Region Row -> Content Region Sequence -> Content Item Sequence
      items.sort! do |a, b|
        # Section
        result = a.section.sequence <=> b.section.sequence
        result.zero? or next result

        # Page
        result = a.page.number <=> b.page.number
        result.zero? or next result

        # Content Region Row
        result = a.content_region.row_sequence <=> b.content_region.row_sequence
        result.zero? or next result

        # Content Region Sequence
        result = a.content_region.sequence <=> b.content_region.sequence
        result.zero? or next result

        # Finally, Content Region Sequence
        result = (a.sequence <=> b.sequence)
      end
                       end
  end

private

  def adjacent_outlets(content_item)
    # Find index of this content_item, return adjacent content_items
    index = content_items.map(&:id).index(content_item.id)

    leading_index   = index-1
    following_index = index+1

    leading   = nil
    following = nil

    if leading_index >= 0
      leading = content_items[leading_index]
    end

    if following_index < content_items.length
      following = content_items[following_index]
    end

    [leading, following]
  end

  def render(view)

    leading, trailing = adjacent_outlets
    # leading: The preceding linked story text content item, should there be one.
    # trailing: The subsequent linked story text content item, should there be one.

    if leading
      include_by_line = false
      unset = leading.overrun_html
    else
      # First outlet
      html = $markdown.render(story.body)
      doc = Nokogiri::HTML(html)
      elements = doc.css("body > p")
      include_by_line = true
      unset = elements.to_html
    end

    # Subsequent outlet
    include_continuation = !!trailing
    include_precedent_link = !!leading

    result = ""
    columns.times do |i|
      render_by_line = include_by_line && i.zero?
      render_continuation = include_continuation && i+1 == columns
      render_precedent_link = include_precedent_link && i.zero?

      if render_continuation
        trailing_page = trailing.page
        trailing_section = trailing_page.section
        continuation_text = "Continued on Page #{trailing_page.page_ref}"
        continuation_path = "#{trailing_section.path}##{trailing.id}"
      end

      if render_precedent_link
        # stiched could also work
        leading_page = leading.page
        leading_section = leading_page.section
        precedent_text = "Continued from Page #{leading_page.page_ref}"
        precedent_path = "#{leading_section.path}##{leading.id}"
      end

      column_height = height
      column_height = render_by_line ? column_height - 40 : column_height
      column_height = render_continuation ? column_height - 20 : column_height
      column_height = render_precedent_link ? column_height - 20 : column_height

      service_result = flow_text_service(unset, width: text_column_width, height: column_height)
      content = service_result["html"]
      unset = service_result["overflow_html"]

      result << view.render("content/text_column",
        story: story,
        render_by_line: render_by_line,
        render_continuation: render_continuation,
        continuation_text: continuation_text,
        continuation_path: continuation_path,
        render_precedent_link: render_precedent_link,
        precedent_text: precedent_text,
        precedent_path: precedent_path,
        width: text_column_width,
        height: height,
        content: content
      )

    end

    self.rendered_html = result
    self.overflow_html = unset
    save
    rendered_html
  end

  def flow_text_service(html, options={})
    width  = options[:width]
    height = options[:height]
    overflow_reserve = options[:overflow_reserve]


    # Shortcut
    response = Net::HTTP.post_form(LINEBREAK_SERVICE_URI, {
      "width" => width,
      "height" => height,
      "overflow_reserve" => overflow_reserve,
      "html" => html
    })
    JSON.parse(response.body)
  rescue
    "Linebreak Service Unavailable"
  end

end
