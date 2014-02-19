class ContentItemsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @content_items = ContentItem.asc(:path)
  end

  def new
    @content_item = ContentItem.new

    # Assign section if passed.
    @content_item.section = Section.find(params[:section_id]) if params[:section_id]
  end

  def create
     @page_id = params[:page_id] || content_item_params[:page_id]
    if @page_id
      # TODO: [security] User must have access to the section.
      @page = Page.find(@page_id)
    end

    @content_item = ContentItem.new(content_item_params)

    if @page
      @page.content_items << @content_item
    end

    # Set content_item numbers
    @content_item.sequence = @page.next_content_item_sequence

    # All section must have an organization
    @content_item.organization = current_user.organization

    @content_item.save

    @page.resequence_content_items!

    #redirect_to :back, notice: "ContentItem created successfully."
    redirect_to :back
  end

  def edit
    @content_item = ContentItem.find(params[:id])
  end

  def show
    @content_item = ContentItem.find(params[:id])
  end

  def update
    @content_item = ContentItem.find(params[:id])
    if @content_item.update_attributes(content_item_params)
      redirect_to @content_item, notice: "ContentItem updated successfully."
    else
      render "edit"
    end
  end

  def preview
    # Previews a copy of the section
    @content_item = ContentItem.find(params[:id])
    render text: ContentItemRenderer.new(@content_item).render
  end


private

  def content_item_params
    #params.require(:content_item).permit(:name, :section_id, :source, :layout_id)
    params.fetch(:content_item, {}).permit(:page_id, :column_width, :pixel_height, :row_sequence)
  end

end
