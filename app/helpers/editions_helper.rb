module EditionsHelper
  attr_reader *[
    :layout_module,
    :edition,
    :section,
    :composing,
    :template_name,
    :title
  ]

  attr_accessor :layouts

  alias :composing? :composing

  attr_accessor :asset_recorder

  def layouts
    @layouts ||= []
  end

  def wrap_with(*args)
    layouts << args
  end

  def yield_content(&block)
    content = capture(&block)

    # Decorate view with layout module particularities.
    view = LayoutModule::View.new(self)

    while layout = layouts.pop
      template_name = layout.shift
      template = layout_module.templates[template_name]
      content = template.render(view, *layout) { content }.html_safe
    end

    concat(content)
  end


  # TODO: In time, this logic should be reverse to not rely on exceptions and to
  # check with the layout module first to allow more flexiable overriding.
  def render(name, *args)
    super(name, *args)
  rescue ActionView::MissingTemplate
    view = LayoutModule::View.new(self)
    template = layout_module.templates[name]
    template.render(view, *args).html_safe
  end

  def composer_stylesheet
    stylesheet_link_tag("composer") + "\n"
  end

  def composer_javascript
    content = content_for(:composer_variables)
    content << javascript_include_tag("composer") + "\n"
  end

  def render_content_items(content_region, options={})
    column_width = options[:column_width] || 34 # Standin values
    gutter_width = options[:gutter_width] || 16

    content = ""
    content_region.content_items.each do |content_item|

      content << case content_item
      when HeadlineContentItem then
        render "content/headline", id: content_item.id,
          text: content_item.text,
          style: content_item.style
      when StoryTextContentItem then
        render "content/story", id: content_item.id, anchor: content_item.id, rendered_html: content_item.rendered_html
      when PhotoContentItem then
        options = {}
        options[:id]            = content_item.id
        options[:photo_url]     = content_item.edition_relative_url_path
        options[:photo_width]   = content_region.width
        options[:photo_height]  = content_region.width / content_item.photo.aspect_ratio
        render "content/photo", options
      when VideoContentItem then
        options = {}
        options[:id]                = content_item.id
        options[:video_url]         = content_item.video_url
        options[:video_thumbnail]   = "" #content_region.width

        render "content/video", options
      end
    end
    content
  end

  def fetch_story_fragment(story_name, fragment_index, last_mod_time)
    fragment = $dalli.get "story_fragments/#{story_name}/#{fragment_index}"

    unless fragment && last_mod_time == fragment[:last_mod_time]
      Rails.logger.info "Typesetting Story: #{story_name}, Fragment Index: #{fragment_index}"
      fragment = {
        last_mod_time: last_mod_time,
        payload: yield
      }
      $dalli.set "story_fragments/#{story_name}/#{fragment_index}", fragment
    end

    fragment[:payload]
  end

end
