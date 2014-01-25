require  'layout_module'

class LayoutModule
  class Template
    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(*args)
      context = Context.new(@layout_module, *args)

      # TODO: Resolve extension and location based on search path and extensions
      # (Should be handled by Tilt)

      tilt = Tilt.new("#{@layout_module.root}/views/#{@name}.html.erb")
      tilt.render(context) do
        %q{
        <div class="row">
          <div class="col span24">
            <input class="add-page-btn" type="button" value="Add Page"></input>
          </div>
        </div>
        }
      end
    end
  end
end
