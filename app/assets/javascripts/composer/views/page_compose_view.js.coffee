@Newstime = @Newstime || {}

class @Newstime.PageComposeView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'page-compose'

    @composer = options.composer

    @canvasLayerView = options.canvasLayerView

    #@gridLines = new Newstime.GridLines()
    #@$el.append(@gridLines.el)

    # Configure Grid
    @gridInit()

    @bind 'mouseover',   @mouseover
    @bind 'mouseout',    @mouseout
    @bind 'mousedown',   @mousedown
    @bind 'mouseup',     @mouseup
    @bind 'mousemove',   @mousemove

    @selections = []


  # Sets up and compute grid steps
  gridInit: ->
    ## TODO: Get the offset to be on the grid steps
    columnWidth = 34
    gutterWidth = 16
    columns = 24

    ## Compute Left Steps
    firstStep = gutterWidth/2
    columnStep = columnWidth + gutterWidth
    @leftSteps = _(columns).times (i) ->
      columnStep * i + firstStep

    firstStep = columnWidth
    columnStep = columnWidth + gutterWidth
    @rightSteps = _(columns).times (i) ->
      columnStep * i + firstStep

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    #parseInt(@$el.css('left'))
    #@$el[0].offsetLeft
    #Math.round(@$el.position().left)
    #Math.round(
    Math.round(@$el.offset().left)
    #@$el[0].getBoundingClientRect()


  y: ->
    parseInt(@$el.css('top'))
    @$el[0].offsetTop


  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  mouseover: (e) ->
    #@$el.css border: "solid 1px red"

  mouseout: (e) ->
    #@$el.css border: "none"

  # Applies offset (sort of a hack for now)
  adjustEventXY: (e) ->
    # Apply scroll offset
    e.x -= @x()
    e.y -= @y()


  mouseup: (e) ->
    @adjustEventXY(e) # Could be nice to abstract this one layer up...
    #console.log "mouseup", e

  mousedown: (e) ->
    @adjustEventXY(e) # Could be nice to abstract this one layer up...


    # Receiving a mousedown, is this hitting an existing selection?
    # If it is, make that the active selection, otherwise, draw a new selection.
    # Tool mode would be decent edition here, to avoid drawing on random clicks.
    # If there is an active selection, we first need to check with it if there
    # is something it would like to do with the mouse down, right now there is
    # not, but resizing would be relevant. So, for now, either change selection
    # of draw new box. Hit detection on selection is what we need to consider.



    if @activeSelection
      @activeSelection.deactivate()

    ## We need to create and activate a selection region (Marching ants would be nice)
    selection = new Newstime.Selection() # Needs to be local to the "page"

    @selections.push selection

    @activeSelection = selection
    @trackingSelection = selection
    @$el.append(selection.el)

    selection.beginSelection(@snapToGridLeft(e.x), e.y)

    @trigger 'tracking', this # Enters into tracking mode.

  # Utility function
  closest: (goal, ary) ->
    closest = null
    $.each ary, (i, val) ->
      if closest == null || Math.abs(val - goal) < Math.abs(closest - goal)
        closest = val
    closest

  snapToGridLeft: (value) ->
    @closest(value , @leftSteps)

  snapToGridRight: (value) ->
    @closest(value , @rightSteps)

  mousemove: (e) ->
    @adjustEventXY(e) # Could be nice to abstract this one layer up...

    if @trackingSelection
      @trackingSelection.$el.css
        width: @snapToGridRight(e.x - @trackingSelection.anchorX)
        height: e.y - @trackingSelection.anchorY
      return true

  mouseup: (e) ->
    if @trackingSelection
      @trackingSelection = null # TODO: Should still be active, just not tracking
      @trigger 'tracking-release', this
