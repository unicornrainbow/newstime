class SectionCompiler
  attr_reader :section, :html

  def initialize(section)
    @section = section
    @edition = @section.edition
    @pages         = @section.pages || []
    @layout_name   = @edition.layout_name
    @template_name = @section.template_name.presence || @edition.default_section_template_name
    @title         = @section.page_title.presence || @edition.page_title
    @layout_module = LayoutModule.new(@layout_name) # TODO: Rename to MediaModule
    @content_item = ContentItem.new
  end

  def compile!
    @controller = EditionsController.new
    @controller.instance_variable_set(:@composing, false)
    @controller.instance_variable_set(:@section, @section)
    @controller.instance_variable_set(:@edition, @edition)
    @controller.instance_variable_set(:@pages, @pages)
    @controller.instance_variable_set(:@layout_name, @layout_name)
    @controller.instance_variable_set(:@template_name, @template_name)
    @controller.instance_variable_set(:@title, @title)
    @controller.instance_variable_set(:@layout_module, @layout_module)

    # This is almost there, but needs to be completly out of the context of a
    # request. Nice start.
    @controller.render "compose", layout: 'layout_module'

     #view = ActionController::Base.new.view_context
     #view.extend ApplicationHelper
     #view.extend EditionsHelper
     #view.instance_variable_set(:@layout_module, LayoutModule.new('sfrecord'))
     #LayoutModule::View.new(view)

    @html = "hello"
  end

end
