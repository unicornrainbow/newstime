@Newstime = @Newstime || {}

class @Newstime.PageComposeView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'page-compose'

    @eventCaptureScreen = new Newstime.EventCaptureScreen()
    @$el.append(@eventCaptureScreen.el)

    @gridLines = new Newstime.GridLines()
    @$el.append(@gridLines.el)

    @eventCaptureScreen.bind 'mousedown', @mousedown

  mousedown: (e) =>
    @trackingSelection = true

    # We need to create and activate a selection region (Marching ants would be nice)
    selection = new Newstime.Selection() # Needs to be local to the "page"
    @$el.append(selection.el)


    closestFn = (goal, ary) ->
      closest = null
      $.each ary, (i, val) ->
        if closest == null || Math.abs(val - goal) < Math.abs(closest - goal)
          closest = val
      closest

    # TODO: Get the offset to be on the grid steps
    columnWidth = 34
    gutterWidth = 16
    columns = 24

    # Compute Left Steps
    firstStep = gutterWidth/2
    columnStep = columnWidth + gutterWidth
    leftSteps = _(columns).times (i) ->
      columnStep * i + firstStep

    firstStep = columnWidth
    columnStep = columnWidth + gutterWidth
    rightSteps = _(columns).times (i) ->
      columnStep * i + firstStep


    x = closestFn(e.offsetX, leftSteps)
    selection.beginSelection(x, e.offsetY)

    @eventCaptureScreen.bind 'mousemove', (e) ->
      # TODO: Width needs to be one of certain allowable values

      width = closestFn(e.offsetX - selection.anchorX, rightSteps)
      selection.$el.css
        width: width
        height: e.offsetY - selection.anchorY

    @eventCaptureScreen.bind 'mouseup', (e) =>
      @eventCaptureScreen.unbind('mousemove')
      @eventCaptureScreen.unbind('mouseup')
