class ContentItemsController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token, only: :update
  respond_to :html, :json

  def index
    @content_items = ContentItem.asc(:path)
  end

  def new
    @content_item = ContentItem.new

    # Assign section if passed.
    @content_item.section = Section.find(params[:section_id]) if params[:section_id]
  end

  def create
    @edition = Edition.find(params[:edition_id])

    # HACK: So Mongoid pickups logic for the sub type relations.
    @content_item = content_item_params['_type'].constantize.new(content_item_params)

    @edition.content_items << @content_item

    @content_item.save

    #@content_item.typeset! if @content_item.is_a?(StoryTextContentItem)

    redirect_to :back
  end

  def edit
    @content_item = ContentItem.find(params[:id])
  end

  def show
    @content_item = ContentItem.find(params[:id])
  end

  def update
    @edition = Edition.find(params[:edition_id])
    @content_item = @edition.content_items.find(params[:id])
    @content_item.update_attributes(content_item_params)
    @content_item.typeset! if @content_item.is_a?(StoryTextContentItem)
    #render text: 'ok'
    respond_with @content_item
  end


  def destroy
    @edition = Edition.find(params[:edition_id])
    @content_item = @edition.content_items.find(params[:id])
    @content_item.destroy
    @edition.save

    head :no_content
  end

  # Returns an html form for creating a content item for consumption over ajax.
  #
  # Example request:
  #
  #   http://press.newstime.io/content_items/fields?type=HeadlineContentItem
  #
  def form
    raise SecuityException unless [
      "HeadlineContentItem",
      "StoryTextContentItem",
      "PhotoContentItem",
      "VideoContentItem",
      "HorizontalRuleContentItem"
    ].include?(params[:type])
    @content_item = params[:type].camelize.constantize.new
    render layout: false
  end

private

  def content_item_params
    #params.require(:content_item).permit(:name, :section_id, :source, :layout_id)
    shared_params = [
      :content_region_id, :_type, :text, :columns, :story_id, :caption,
      :font_size, :font_weight, :font_family, :font_style, :text_align,
      :margin_top, :margin_bottom, :padding_top, :padding_bottom, :height
    ]
    video_params = [:video_id]
    photo_params = [:photo_id]
    horizontal_rule_params = [:style_class]

    params.fetch(:content_item, {}).permit(*(shared_params + video_params + photo_params + horizontal_rule_params))
  end

end
