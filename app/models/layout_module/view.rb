require  'layout_module'

class LayoutModule
  class View < SimpleDelegator
    def render(name, *args, &block)
      #layout_module.partials[name].render(self, *args, &block)
      content = capture(&block) if block_given?
      content = layout_module.partials[name].render(self, *args) { content }

      #concat(layout_module.partials[name].render(self, *args) { capture(&block) })
    end

    # Render content within a partial serving as a layout.
    def render_layout(name, *args, &block)
      content = page_content
      @__layout = layout_module.partials[name]
      content = @__layout.render(self, *args) { content }
      content = block.call
      content = layout_module.partials[name].render(self, *args) { content }
      concat(content)


      #capture(&block)
      #layout_module.partials[name].render(self, *args, &block)

      # This was the money that emit things
      #concat(layout_module.partials[name].render(self, *args, &block).html_safe)

      # Stand in line
      #layout_module.partials[name].render(self, *args, &block).html_safe


      #layout_module.partials[name].render(self, *args) { capture(&block) }.html_safe
      #concat(layout_module.partials[name].render(self, *args) { capture { block.call.html_safe } }.html_safe

      # I need to some how access the stuff that would be yield in the parrent
      # context
      #content = capture(&block)
      #throw content
      #
      #
      #concat(block.call("ads"))


      #layout_module.partials[name].render(self, *args) { capture(&block) }.html_safe


    end

    def capture(&block)
      view = LayoutModule::CaptureConcat.new(self)
      #block.bind(view).call
      view.instance_eval(&proc)
      #Could I evaluate the block in the
      #block.call
      #Rails.logger.info "Call Capture"
      #""
    end

    def stylesheet_link_tag(name)
      %Q{<link href="#{name}.css" rel="stylesheet" media="screen" />}
    end

    def javascript_include_tag(name)
      %Q{<script src="#{name}.js" type="text/javascript"></script>}
    end

  end
end
