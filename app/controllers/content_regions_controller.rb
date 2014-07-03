class ContentRegionsController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  def index
    @content_regions = ContentRegion.asc(:path)
  end

  def new
    @content_region = ContentRegion.new

    # Assign section if passed.
    @content_region.section = Section.find(params[:section_id]) if params[:section_id]
  end

  def create
     @page_id = params[:page_id] || content_region_params[:page_id]
    if @page_id
      # TODO: [security] User must have access to the section.
      @page = Page.find(@page_id)
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

    @page.resequence_content_regions!

    #redirect_to :back, notice: "ContentRegion created successfully."
    redirect_to :back
  end

  def edit
    @content_region = ContentRegion.find(params[:id])
  end

  def show
    @content_region = ContentRegion.find(params[:id])
    render layout: false
  end

  def update
    @content_region = ContentRegion.find(params[:id])
    @content_region.update_attributes(content_region_params)
    render text: 'ok'
  end

  def destroy
    @content_region = ContentRegion.find(params[:id]).destroy
    # TODO: Should delete content items that are ophaned
    render text: 'ok'
  end

  def preview
    # Previews a copy of the section
    @content_region = ContentRegion.find(params[:id])
    render text: ContentRegionRenderer.new(@content_region).render
  end


private

  def content_region_params
    #params.require(:content_region).permit(:name, :section_id, :source, :layout_id)
    params.fetch(:content_region, {}).permit(:page_id, :column_width, :pixel_height, :row_sequence)
  end

end
