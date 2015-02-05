#= require ../mixins/draggable
#
# CanvasItemView are CanvasItems which can appear on the canvas, or within a
# canvas like region like a group. Both ContentItemView and GroupViews are
# CanvasItemViews.
#
# CanvasItemView is a module class. Mix into target class using @include.
#
#   Class ChildClass
#     @include Newstime.CanvasItemView
#
class @Newstime.CanvasItemView
  @include Newstime.Draggable

  @getter 'top',  -> @model.get('top')
  @getter 'left', -> @model.get('left')

  @getter 'pageView', -> @_pageView

  @setter 'pageView', (value) ->
    @_pageView = value
    if value && value.model.id
      @model.set(page_id: value.model.id)

  mouseup: (e) ->
    #TODO: Need to remove this code, which is no longer used do to selection
    #view

    if @resizing
      @resizing = false
      @resizeMode = null

      @composer.hideVerticalSnapLine() # Ensure vertical snaps aren't showing.
      # Reset drag handles, clearing if they where active
      _.each @dragHandles, (h) -> h.reset()
      @trigger 'resized'

    if @moving?
      @moving = false

    @trigger 'tracking-release', this

  mouseover: (e) ->
    @hovered = true
    #@$el.addClass 'hovered'
    @outlineView.show()
    @composer.pushCursor @getCursor()

  getCursor: ->
    'default'

  mouseout: (e) ->

    if @hoveredHandle
      @hoveredHandle.trigger 'mouseout', e
      @hoveredHandle = null

    @hovered = false
    #@$el.removeClass 'hovered'
    @outlineView.hide()
    @composer.popCursor()


  setSizeAndPosition: (attributes) ->
    @model.set(attributes)
