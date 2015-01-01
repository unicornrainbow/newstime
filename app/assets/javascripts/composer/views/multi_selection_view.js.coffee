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

    @bind 'mousedown', @mousedown

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


  # Detects a hit of the selection
  hit: (x, y) ->
    @selection.hit(x, y)

  destroy: ->
    @remove()

  mousedown: (e) ->
    #return unless e.button == 0 # Only respond to left button mousedown.

    #if @hoveredHandle
      #@trackResize @hoveredHandle.type
    #else
      #position = @selection.getPosition()
      #@trackMove(e.x - position.left, e.y - position.top)

      # OK, so just a note, but looks like moveing an object is actually a
      # feature of the canvas view layer, which should on each move, figure out
      # which to query into to check against snap points, and infact, can do
      # this against multi pages, and even other objects, and will also need to
      # do similar for highlighting snap points.

  #trackMove: (offsetX, offsetY) ->
    #@pageView.computeTopSnapPoints()
    #@pageView.collectLeftEdges(@model)
    #@pageView.collectRightEdges(@model)
    #@moving      = true
    #@orginalPositionX = @model.get('left')
    #@orginalPositionY = @model.get('top')
    #@moveOffsetX = offsetX
    #@moveOffsetY = offsetY
    #@trigger 'tracking', this
