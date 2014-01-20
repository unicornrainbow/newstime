# layout_module = LayoutModule.new('sfrecord/v1')
# template = layout_module.find_template('main')
# template.render(title: "San Francisco Record")

module LayoutModule

  def initialize(name)
    @name = name
    @layout_module_root = "#{Rails.root}/vendor/layout_modules/#{@name}"
  end

  def render
    template = Tilt.new("#{@layout_module_root}/views/main.html.erb")
    context = Context.new(title: "San Francisco Record")
    template.render(context) do
      %q{
      <div class="row">
        <div class="col span24">
          Content
        </div>
      </div>
      }
    end
  end


  class Template

    def self.find(name)

    end

  end

  class Context
    attr_accessor :title

    def initialize(opts={})
      @title = opts.delete(:title)
    end

    def stylesheet_link_tag(name)
      %Q{<link href="#{name}.css" rel="stylesheet" media="screen" />}
    end

    def javascript_include_tag(name)
      %Q{<script src="#{name}.js" type="text/javascript"></script>}
    end

    def render(name, *args)

    end
  end

end
