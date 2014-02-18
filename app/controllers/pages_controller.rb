class PagesController < ApplicationController

  before_filter :authenticate_user!

  def index
    @pages = Page.asc(:path)
  end

  def new
    @page = Page.new

    # Assign section if passed.
    @page.section = Section.find(params[:section_id]) if params[:section_id]
  end

  def create
    if params[:section_id]
      # TODO: [security] User must have access to the section.
      @section = Section.find(params[:section_id])
    end

    @page = Page.new(page_params)

    if @section
      @section.pages << @page
    end

    # Set page numbers
    @page.number = @section.next_page_number

    # All section must have an organization
    @page.organization = current_user.organization

    @page.save

    @section.renumber_pages!

    #redirect_to :back, notice: "Page created successfully."
    redirect_to :back
  end

  def edit
    @page = Page.find(params[:id])
  end

  def show
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(page_params)
      redirect_to @page, notice: "Page updated successfully."
    else
      render "edit"
    end
  end

  def preview
    # Previews a copy of the section
    @page = Page.find(params[:id])
    render text: PageRenderer.new(@page).render
  end


private

  def page_params
    #params.require(:page).permit(:name, :section_id, :source, :layout_id)
    params.fetch(:page, {}).permit(:name, :section_id, :source, :layout_id)
  end

end
