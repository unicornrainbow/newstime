class ContentRegionsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @content_regions = ContentRegion.asc(:path)
  end

  def new
    @content_region = ContentRegion.new

    # Assign section if passed.
    @content_region.section = Section.find(params[:section_id]) if params[:section_id]
  end

  def create
    if params[:page_id]
      # TODO: [security] User must have access to the section.
      @page = Page.find(params[:section_id])
    end

    @content_region = ContentRegion.new(content_region_params)

    if @page
      @page.content_regions << @content_region
    end

    # Set content_region numbers
    @content_region.sequence = @page.next_content_region_sequence

    # All section must have an organization
    @content_region.organization = current_user.organization

    @content_region.save

    @section.resequence_content_regions!

    #redirect_to :back, notice: "ContentRegion created successfully."
    redirect_to :back
  end

  def edit
    @content_region = ContentRegion.find(params[:id])
  end

  def show
    @content_region = ContentRegion.find(params[:id])
  end

  def update
    @content_region = ContentRegion.find(params[:id])
    if @content_region.update_attributes(content_region_params)
      redirect_to @content_region, notice: "ContentRegion updated successfully."
    else
      render "edit"
    end
  end

  def preview
    # Previews a copy of the section
    @content_region = ContentRegion.find(params[:id])
    render text: ContentRegionRenderer.new(@content_region).render
  end


private

  def content_region_params
    #params.require(:content_region).permit(:name, :section_id, :source, :layout_id)
    params.fetch(:content_region, {}).permit(:page_id)
  end

end
