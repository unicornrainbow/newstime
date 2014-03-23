require "net/http"
require "uri"

class StoryTextContentItem < ContentItem
  field :columns, type: Integer, default: 1

  # Render fields
  #field :rendered_at, type: DateTime
  field :rendered_html, type: String
  field :overflow_html, type: String
  #field :include_by_line, type: Boolean
  #field :span_by_line, type: Boolean # Should the by line span columns, if more than one present, or be part of the first column.
  #

  LINEBREAK_SERVICE_URL = ENV['LINEBREAK_SERVICE_URL']

  belongs_to :story, inverse_of: :story_text_content_items

  # TODO: Store rendered_html and overflow html
  #
  def adjacent_outlets
    # Need all the story text content items, for the story, in this edition
    #
    # Get all story text content items for the story
    #throw linked_content_items = story.story_text_content_items.to_a
    linked_content_items = story.story_text_content_items.to_a

    # Reject, unless for the same edition
    linked_content_items.select! do |content_item|
      content_item.edition.id == edition.id
    end

    # Order them based on Section Sequence -> Page Number -> Content Region Row -> Content Region Sequence -> Content Item Sequence
    linked_content_items.sort! do |a, b|
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

    # Find index of this content_item, return adjacent content_items
    index = linked_content_items.map(&:id).index(self.id)


    leading_index   = index-1
    following_index = index+1

    leading   = nil
    following = nil

    if leading_index >= 0
      leading = linked_content_items[leading_index]
    end

    if following_index < linked_content_items.length
      following = linked_content_items[following_index]
    end

    [leading, following]
  end

  def render(view)

    leading, trailing = adjacent_outlets
    # leading: The preceding linked story text content item, should there be one.
    # trailing: The subsequent linked story text content item, should there be one.

    if leading
      include_by_line = false

      unset = leading.overflow_html
      result = ""
      columns.times do |i|
        render_by_line = include_by_line && i.zero?
        height = render_by_line ? self.height - 40 : self.height

        service_result = flow_text_service(unset, width: text_column_width, height: height)
        content = service_result["html"]
        unset = service_result["overflow_html"]

        result << view.render("content/text_column", story: story, render_by_line: render_by_line, width: text_column_width, height: height, content: content)
      end
      self.rendered_html = result
      self.overflow_html = unset
      save
      rendered_html
    else
      html = $markdown.render(story.body)
      doc = Nokogiri::HTML(html)
      elements = doc.css("body > p")
      include_by_line = true

      unset = elements.to_html
      result = ""
      columns.times do |i|
        render_by_line = include_by_line && i.zero?
        height = render_by_line ? self.height - 40 : self.height

        service_result = flow_text_service(unset, width: text_column_width, height: height)
        content = service_result["html"]
        unset = service_result["overflow_html"]

        result << view.render("content/text_column", story: story, render_by_line: render_by_line, width: text_column_width, height: height, content: content)
      end
      self.rendered_html = result
      self.overflow_html = unset
      save
      rendered_html
    end
  end

  # Returns the width of each text column
  def text_column_width
    (width - (columns - 1) * gutter_width) / columns
  end

  def gutter_width
    page.gutter_width
  end

  def flow_text_service(html, options={})
    width  = options[:width]
    height = options[:height]
    # Post the to backend service.
    # Return the result.

    uri = URI.parse(LINEBREAK_SERVICE_URL)

    # Shortcut
    response = Net::HTTP.post_form(uri, {
      "width" => width,
      "height" => height,
      "html" => html
    })
    JSON.parse(response.body)
  rescue
    "Linebreak Service Unavailable"
  end
end
