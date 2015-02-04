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
  @getter 'top',  -> @model.get('top')
  @getter 'left', -> @model.get('left')
  @getter 'pageView', -> @_pageView

  @setter 'pageView', (value) ->
    @_pageView = value
    if value && value.model.id
      @model.set(page_id: value.model.id)

  # Moves based on corrdinates and starting offset
  move: (x, y) ->
    geometry = @getGeometry()

    # Adjust x corrdinate
    x -= @moveOffsetX
    #x = Math.min(x, @pageView.getWidth() - @model.get('width')) # Keep on page
    #x = @pageView.snapLeft(x) # Snap

    y = @pageView.snapTop(y - @moveOffsetY)
    @model.set
      left: x
      top: y

  # Resizes based on a top drag
  dragTop: (x, y) ->
    geometry = @getGeometry()
    y = @pageView.snapTop(y)
    @model.set
      top: y
      height: geometry.top - y + geometry.height

  dragRight: (x, y) ->
    geometry = @getGeometry()
    width = x - geometry.left
    width = Math.min(width, @pageView.getWidth() - @model.get('left')) # Keep on page
    width = @pageView.snapRight(width) # Snap

    @model.set
      width: width

  dragBottom: (x, y) ->
    geometry = @getGeometry()
    @model.set
      height: @pageView.snapBottom(y) - geometry.top

  dragLeft: (x, y) ->
    geometry = @getGeometry()
    snapLeft = @pageView.snapLeft(x)
    if snapLeft
      @composer.showVerticalSnapLine(snapLeft + @pageView.x())
      x = snapLeft
    else
      @composer.hideVerticalSnapLine()

    @model.set
      left: x
      width: geometry.left - x + geometry.width

  dragTopLeft: (x, y) ->
    geometry = @getGeometry()
    x        = @pageView.snapLeft(x)
    y        = @pageView.snapTop(y)
    @model.set
      left: x
      top: y
      width: geometry.left - x + geometry.width
      height: geometry.top - y + geometry.height

  dragTopRight: (x, y) ->
    geometry = @getGeometry()
    width = @pageView.snapRight(x - geometry.left)
    y = @pageView.snapTop(y)
    @model.set
      top: y
      width: width
      height: geometry.top - y + geometry.height

  dragBottomLeft: (x, y) ->
    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()

    snapLeft = @pageView.snapLeft(x)

    if snapLeft
      @composer.drawVerticalSnapLine(snapLeft)
      x = snapLeft

    y = @pageView.snapBottom(y)
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: y - geometry.top

  dragBottomRight: (x, y) ->
    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()
    width     = x - geometry.left
    y         = @pageView.snapBottom(y)

    snapRight = @pageView.snapRight(width)

    if snapRight
      @composer.drawVerticalSnapLine(snapRight + geometry.left)
      width = snapRight

    @model.set
      width: width
      height: y - geometry.top


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


#@Newstime.CanvasItemView = {

  #yo: ->


#}


# Need to figure out a way to copy getters and setters if they are going to be
# part of the module...
#Object.defineProperties @Newstime.CanvasItemView,
  #top:
    #get: -> @model.get('top')
    #enumerable: true

  #left:
    #get: -> @model.get('left')
    #enumerable: true

  #pageView:
    #get: -> @_pageView
    #set: (value) ->
      #@_pageView = value
      #if value && value.model.id
        #@model.set(page_id: value.model.id)
