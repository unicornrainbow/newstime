@Newstime = @Newstime || {}

class @Newstime.PageComposeView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'page-compose'

    @eventCaptureScreen = new Newstime.EventCaptureScreen()
    @$el.append(@eventCaptureScreen.el)

    @eventCaptureScreen.bind 'mousedown', @mousedown

  mousedown: (e) =>
    @trackingSelection = true

    # We need to create and activate a selection region (Marching ants would be nice)
    selection = new Newstime.Selection() # Needs to be local to the "page"
    @$el.append(selection.el)

    # TODO: Need to offset from the region
    selection.beginSelection(e.offsetX, e.offsetY)

    @eventCaptureScreen.bind 'mousemove', (e) =>
      selection.$el.css
        width: e.offsetX - selection.anchorX
        height: e.offsetY - selection.anchorY

    @eventCaptureScreen.bind 'mouseup', (e) =>
      @eventCaptureScreen.unbind('mousemove')
      @eventCaptureScreen.unbind('mouseup')
