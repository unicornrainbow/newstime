require  'layout_module'

class LayoutModule
  class Template
    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(view, *args, &block)
      _layouts, view.layouts = view.layouts, []

      # Acquire the tilt template
      file_name = "#{@layout_module.root}/views/#{@name}.html"

      # Resolve which type of template (erb, haml, slim...)
      # TODO: There should be a cleaner way to do this.
      ext = SUPPORTED_TEMPLATE_FORMATS.find { |ext| File.exists?("#{file_name}.#{ext}") }
      file_name << ".#{ext}"

      tilt = Tilt.new(file_name)

      # Capture content from block.
      content = view.capture(&block) if block_given?

      # Render using the LayoutModule::View wrapped view, injecting the rendered
      # content and passing the args.
      content = tilt.render(view, *args) { content }

      while template_name = view.layouts.pop
        content = view.layout_module.templates[template_name].render(view, *args) { content }
      end

      view.layouts = _layouts

      content
    end
  end
end
