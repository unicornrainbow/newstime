@Newstime = @Newstime || {}

class @Newstime.Selection extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection'

  beginSelection: (anchorX, anchorY) ->
    #@trackingSelection = true

    @anchorX = anchorX
    @anchorY = anchorY

    @$el.addClass "resizable"
    @$el.css
      left: @anchorX
      top: @anchorY

    # Track mouse
    #$(window).bind('mousemove', @trackSelection)
