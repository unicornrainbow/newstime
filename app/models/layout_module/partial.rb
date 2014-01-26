require  'layout_module'

class LayoutModule
  class Partial
    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(view, *args, &block)
      # This is weird, but passing content in because it is needed.
      #context = Context.new(@layout_module, *args)

      # Prefixed last segment of name with an underscore by convention.
      segments = @name.split('/')
      segments[-1] = "_" << segments[-1]
      @name = segments.join('/')

      file_name = "#{@layout_module.root}/views/#{@name}.html"

      # Resolve which type of template (erb, haml, slim...)
      # TODO: There should be a cleaner way to do this.
      ext = SUPPORTED_TEMPLATE_FORMATS.find { |ext| File.exists?("#{file_name}.#{ext}") }
      file_name << ".#{ext}"

      tilt = Tilt.new(file_name)

      #tilt.render(context, *args, &block)
      tilt.render(view, *args) { view.capture(&block) }
      #""
      #if block_given?
        ##tilt.render(context, *args) { capture(&block) }
        ##tilt.render(context, *args) { capture(block.to_proc)  }
        ##tilt.render(context, *args, &capture(block))
        ##
      #else
        #tilt.render(context, *args)
      #end
    end
  end
end
