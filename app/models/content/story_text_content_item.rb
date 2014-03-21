require "net/http"
require "uri"

module Content
  class StoryTextContentItem < ContentItem
    field :columns, type: Integer, default: 1

    # Render fields
    #field :rendered_at, type: DateTime
    #field :rendered_html, type: String
    #field :include_by_line, type: Boolean
    #field :span_by_line, type: Boolean # Should the by line span columns, if more than one present, or be part of the first column.
    #

    LINEBREAK_SERVICE_URL = ENV['LINEBREAK_SERVICE_URL']

    belongs_to :story

    # TODO: Store rendered_html and overflow html

    def render(view)
      html = $markdown.render(story.body)
      doc = Nokogiri::HTML(html)
      elements = doc.css("body > p")
      include_by_line = true
      #updated_at

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
      result

      #rendered_html
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
end
