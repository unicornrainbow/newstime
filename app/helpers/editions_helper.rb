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


  def underscore_key(key)
    key.to_s.underscore.to_sym
  end

  #def convert_hash_keys(hash)
    #Hash[hash.map { |k, v| [underscore_key(k), v] }]
  #end

  #def slice(object, *keys)
    #Hash[keys.map { |key|  [key, object.send(key)] }]
  #end

  def render_content_item(content_item, options={})
    content = ""

    options = {}
    options[:id]     = content_item.id
    options[:top]    = content_item.top - content_item.page.top
    options[:left]   = content_item.left
    options[:width]  = content_item.width
    options[:height] = content_item.height
    options[:z_index] = content_item.z_index

    content << case content_item
    when HeadlineContentItem then
      options[:style] = content_item.style

      options[:text] = if content_item.text
        text = content_item.text.dup
        text.gsub(/(?:\n\r?|\r\n?)/, '<br>') # Convert newlines into linebreaks
      else
        ''
      end

      render "content/headline", options
    when StoryTextContentItem then
      render "content/story", id: content_item.id, anchor: content_item.id, rendered_html: content_item.rendered_html
    when TextAreaContentItem then
      options[:text] = content_item.text
      options[:anchor] = "#{content_item.page.page_ref}/#{content_item.story_title}"
      options[:rendered_html] = content_item.rendered_html

      render "content/text_area", options
    when PhotoContentItem then
      options[:photo_url]     = content_item.edition_relative_url_path
      options[:caption]  = content_item.caption
      options[:caption_height]  = content_item.caption_height
      options[:photo_width]   = content_item.width
      #options[:photo_height]  = content_region.width / content_item.photo.aspect_ratio
      options[:photo_height]  = content_item.height - content_item.caption_height.to_i
      options[:show_caption]  = content_item.show_caption
      render "content/photo", options
    when VideoContentItem then
      options[:video_url]         = content_item.video_url
      options[:video_thumbnail]   = content_item.cover_image_url

      render "content/video", options
    when HorizontalRuleContentItem then
      options = {}
      options[:style_class]  = content_item.style_class # short-hr, news-column-double-rule

      render "content/horizontal_rule", options

    when BoxContentItem then
      options = {}
      options[:id]     = content_item.id

      render "content/box", options
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
