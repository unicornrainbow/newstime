@Newstime = @Newstime || {}

class @Newstime.Selection extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection'

  activate: ->
    @active = true
    @$el.addClass 'resizable'

  deactivate: ->
    @active = false
    @$el.removeClass 'resizable'

  beginSelection: (anchorX, anchorY) ->
    #@trackingSelection = true

    @activate()

    @anchorX = anchorX
    @anchorY = anchorY

    @$el.css
      left: @anchorX
      top: @anchorY

    # Track mouse
    #$(window).bind('mousemove', @trackSelection)
