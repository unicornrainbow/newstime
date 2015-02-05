#= require ../mixins/draggable
#
# CanvasItemView are CanvasItems which can appear on the canvas, or within a
# canvas like region like a group. Both ContentItemView and GroupViews are
# CanvasItemViews.
#
class @Newstime.CanvasItemView extends @Newstime.View
  @include Newstime.Draggable

  @getter 'top',  -> @model.get('top')
  @getter 'left', -> @model.get('left')
  @getter 'pageView', -> @_pageView

  @setter 'pageView', (value) ->
    @_pageView = value
    if value && value.model.id
      @model.set(page_id: value.model.id)

  select: (selectionView) ->
    unless @selected
      @selected = true
      @selectionView = selectionView

  deselect: ->
    if @selected
      @selected = false
      @selectionView = null
      @trigger 'deselect', this

  setSizeAndPosition: (attributes) ->
    @model.set(attributes)
