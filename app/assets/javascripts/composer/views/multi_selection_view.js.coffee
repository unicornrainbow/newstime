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

  mousedown: ->
    console.log 'hit me'
