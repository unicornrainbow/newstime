class EditionsController < ApplicationController
  wrap_parameters include: [*Edition.attribute_names, :sections_attributes, :pages_attributes, :content_items_attributes]

  before_filter :authenticate_user!, except: :index
  before_filter :find_edition, only: [:compose, :preview, :compile, :download]

  skip_filter :verify_authenticity_token, only: [:delete, :update] # TODO: Should remove this

  respond_to :html, :json

  def index
    redirect_to new_user_session_path and return unless current_user
    @editions = current_user.organization.editions.desc(:updated_at)
  end

  def new
    @publication = params[:publication_id] ? Publication.find(params[:publication_id]) : Publication.first
    @edition = @publication.build_edition
  end

  def create
    @publication = Publication.find(edition_params[:publication_id])


    # Construct new edition with sections and pages
    @edition = Edition.new(edition_params)
    @edition.organization = @publication.organization

    sections_attributes = JSON.parse(@publication.default_section_attributes)
    sections_attributes.each do |section_attributes|
      pages_attributes = section_attributes.delete("pages_attributes")
      section = @edition.sections.build(section_attributes)
      if pages_attributes
        pages_attributes.each do |page_attributes|
          page = @edition.pages.build(page_attributes)
          page.section = section
        end
      end
    end

    if @edition.save
      #redirect_to @edition, notice: "Edition created successfully."
      redirect_to compose_edition_path(@edition)
    else
      render "new"
    end
  end

  def edit
    @edition = Edition.find(params[:id])
  end


  def compose
    flash[:notice] # Clear flash, since it's not currently displayed anywhere

    # Redirect to main if no path specified.
    redirect_to (send("#{params[:action]}_edition_path".to_sym, @edition) + '/main.html') and return unless params['path']

    # Only respond to requests with an explict .html extension.
    not_found unless request.original_url.match(/\.html$/)

    # Set composing flag as indication to layout_module.
    @composing = params[:action] == 'compose'

    # Reconstruct path with extension
    @path = "#{params['path']}.html"

    # Find section by path of edition.
    @section       = @edition.sections.find_by(path: @path)

    @pages         = @section.pages || []
    @layout_name   = @edition.layout_name
    @template_name = @section.template_name.presence || @edition.default_section_template_name
    @title         = @section.page_title.presence || @edition.page_title
    @layout_module = LayoutModule.new(@layout_name) # TODO: Rename to MediaModule
    @content_item = ContentItem.new

    render 'compose', layout: 'layout_module'
  end

  alias :preview :compose

  def update
    @edition = Edition.find(params[:id])
    @edition.update_attributes(edition_params)
    respond_with @edition.to_json
  end

  def show
    @edition = Edition.find(params[:id])
    respond_to do |format|
      format.html { redirect_to action: :compose }
      format.json { respond_with @edition }
    end
  end

  def destroy
    @edition = Edition.find(params[:id]).destroy
    redirect_to editions_path, notice: "Edition deleted successfully."
  end

  def download
    render layout: false
  end

  def compile
    @path = "#{params['path']}.html"
    @section = @edition.sections.where(path: @path).first
    section_compiler = SectionCompiler.new(@section)
    section_compiler.compile!
    render text: section_compiler.html
  end

private

  def find_edition
    @edition = Edition.find(params[:id])
  end

  def edition_params
    params.require(:edition).
      permit(:name, :source, :page_title, :masthead_id, :layout_id,
             :layout_name, :default_section_template_name, :publish_date,
             :store_link, :fmt_price, :volume_label, :publication_id, :price,
             :_id, :created_at, :updated_at, :page_pixel_height,
             :organization_id, :state_event,
             #:content_items_attributes => [:_id, :height, :left, :top, :width, :page_id, :_type, :created_at, :updated_at]
             :sections_attributes => [Section.attribute_names],
             :pages_attributes => [Page.attribute_names],
             :content_items_attributes => [ContentItem.attribute_names + [:text, :font_size, :font_weight, :columns, 'margin-top', 'margin-left', 'margin-bottom', 'margin-right']]
            )
  end

end
