require  'layout_module'

class LayoutModule
  class Partial
    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(view, *args, &block)
      file_name = "#{@layout_module.root}/views/#{@name}.html"

      # Resolve which type of template (erb, haml, slim...)
      # TODO: There should be a cleaner way to do this.
      ext = SUPPORTED_TEMPLATE_FORMATS.find { |ext| File.exists?("#{file_name}.#{ext}") }
      file_name << ".#{ext}"

      tilt = Tilt.new(file_name)

      tilt.render(view, *args) { view.capture(&block) }
    end
  end
end
