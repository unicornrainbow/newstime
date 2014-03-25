class EditionsController < ApplicationController
  before_filter :authenticate_user!, except: :index
  before_filter :find_edition, only: [:compose, :preview]

  skip_filter :verify_authenticity_token, only: :delete

  respond_to :html

  def index
    redirect_to new_user_session_path and return unless current_user
    @editions = current_user.organization.editions.desc(:updated_at)
  end

  def new
    @publication = Publication.first
    @edition = @publication.build_edition
  end

  def create
    @publication = Publication.find(edition_params[:publication_id])
    @edition = Edition.new(edition_params.merge(sections_attributes: JSON.parse(@publication.default_section_attributes)))
    @edition.organization = @publication.organization

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

    # Find section by path off of edtion.
    @section       = @edition.sections.where(path: @path).first

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
    if @edition.update_attributes(edition_params)
      #redirect_to compose_edition_url(@edition), notice: "Edition updated successfully."
      redirect_to :back
    else
      render "edit"
    end
  end

  def show
    @edition = Edition.find(params[:id])
    @sections = @edition.sections
  end

  def destroy
    @edition = Edition.find(params[:id]).destroy
    redirect_to editions_path, notice: "Edition deleted successfully."
  end

  def download
  end

  def test
  end

private

  def find_edition
    @edition = Edition.find(params[:id])
  end

  def edition_params
    params.require(:edition).permit(:name, :source, :page_title, :masthead_id, :layout_id, :layout_name, :default_section_template_name, :publish_date, :store_link, :fmt_price, :volume_label, :publication_id)
  end

end
