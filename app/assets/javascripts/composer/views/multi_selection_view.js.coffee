class @Newstime.MultiSelectionView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-view resizable'

    @selection = options.selection
    @composer = options.composer

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    @listenTo @selection, 'change', @render

    @bind
      'mousedown': @mousedown
      'mousemove': @mousemove
      'mouseup': @mouseup
      'keydown': @keydown

  render: ->
    position = @selection.getPosition()

    ## Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)

  keydown: (e) ->
    switch e.keyCode
      when 71 # g
        @createGroup() if e.altKey

      when 27 # ESC
        @composer.clearSelection()

  createGroup: ->
    @composer.createGroup @selection.models, (group) =>
      @composer.selectGroup(group)

  # Detects a hit of the selection
  hit: (x, y) ->
    @selection.hit(x, y)

  destroy: ->
    @remove()

  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    if @hoveredHandle
      @trackResize @hoveredHandle.type
    else
      position = @selection.getPosition()
      @trackMove(e.x - position.left, e.y - position.top)

       #OK, so just a note, but looks like moveing an object is actually a
       #feature of the canvas view layer, which should on each move, figure out
       #which to query into to check against snap points, and infact, can do
       #this against multi pages, and even other objects, and will also need to
       #do similar for highlighting snap points.

  trackMove: (offsetX, offsetY) ->
    #@pageView.computeTopSnapPoints()
    #@pageView.collectLeftEdges(@model)
    #@pageView.collectRightEdges(@model)
    @moving      = true

    position = @selection.getPosition()
    @orginalPositionX = position.left
    @orginalPositionY = position.top
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this


  mousemove: (e) ->
    #@adjustEventXY(e)
    if @resizing
      switch @resizeMode
        when 'top'          then @dragTop(e.x, e.y)
        when 'right'        then @dragRight(e.x, e.y)
        when 'bottom'       then @dragBottom(e.x, e.y)
        when 'left'         then @dragLeft(e.x, e.y)
        when 'top-left'     then @dragTopLeft(e.x, e.y)
        when 'top-right'    then @dragTopRight(e.x, e.y)
        when 'bottom-left'  then @dragBottomLeft(e.x, e.y)
        when 'bottom-right' then @dragBottomRight(e.x, e.y)

    else if @moving
      @move(e.x, e.y, e.shiftKey)


  # Moves based on corrdinates and starting offset
  move: (x, y, shiftKey=false) ->
    x -= @moveOffsetX
    y -= @moveOffsetY



    @composer.moveItem(this, x, y, @orginalPositionX, @orginalPositionY, shiftKey)

  setSizeAndPosition: (value) ->
    @selection.setSizeAndPosition(value)

  getBounds: ->
    bounds = _.clone(@selection.getPosition())
    bounds.bottom = bounds.top + bounds.height
    bounds.right = bounds.left + bounds.width
    delete bounds.width
    delete bounds.height
    bounds


  mouseup: (e) ->
    if @resizing
      @resizing = false
      @resizeMode = null

      @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
      # Reset drag handles, clearing if they where active
      _.each @dragHandles, (h) -> h.reset()
      @canvasItemView.trigger 'resized'

    if @moving
      @moving = false

      @composer.clearVerticalSnapLines()

    @trigger 'tracking-release', this
