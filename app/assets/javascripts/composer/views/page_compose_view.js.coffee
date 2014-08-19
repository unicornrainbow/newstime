@Newstime = @Newstime || {}

class @Newstime.PageComposeView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'page-compose'

    @composer = options.composer

    @coverLayerView = options.coverLayerView

    @gridLines = new Newstime.GridLines()
    @$el.append(@gridLines.el)

    @bind 'mouseover', @mouseover
    @bind 'mouseout', @mouseout
    @bind 'mousedown', @mousedown

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
    console.log "mouseup", e

  mousedown: (e) ->
    @adjustEventXY(e) # Could be nice to abstract this one layer up...
    console.log "mousedown", e

    @trackingSelection = true

    ## We need to create and activate a selection region (Marching ants would be nice)
    selection = new Newstime.Selection() # Needs to be local to the "page"
    @$el.append(selection.el)


    closestFn = (goal, ary) ->
      closest = null
      $.each ary, (i, val) ->
        if closest == null || Math.abs(val - goal) < Math.abs(closest - goal)
          closest = val
      closest

    ## TODO: Get the offset to be on the grid steps
    columnWidth = 34
    gutterWidth = 16
    columns = 24

    ## Compute Left Steps
    firstStep = gutterWidth/2
    columnStep = columnWidth + gutterWidth
    leftSteps = _(columns).times (i) ->
      columnStep * i + firstStep

    firstStep = columnWidth
    columnStep = columnWidth + gutterWidth
    rightSteps = _(columns).times (i) ->
      columnStep * i + firstStep


    x = closestFn(e.x, leftSteps)
    selection.beginSelection(x, e.y)

    # So now, we need to receive mouse move events until released.


    #@coverLayerView.bind 'mousemove', (e) ->
      ## TODO: Width needs to be one of certain allowable values

      #width = closestFn(e.offsetX - selection.anchorX, rightSteps)
      #selection.$el.css
        #width: width
        #height: e.offsetY - selection.anchorY

    #@coverLayerView.bind 'mouseup', (e) =>
      #@coverLayerView.unbind('mousemove')
      #@coverLayerView.unbind('mouseup')
