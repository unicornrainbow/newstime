# Covers and capture mouse events for relay to interested objects.
class @Newstime.CoverLayerView extends Backbone.View

  events:
    'mousedown': 'mousedown'
    'mouseup': 'mouseup'
    'mousemove': 'mousemove'
    'click': 'click'

  initialize: (options) ->
    @$el.addClass "cover-layer-view"

    @topOffset = options.topOffset # Apply top offset (Allows room for menu)
    @composer = options.composer

    @$el.css top: "#{@topOffset}px"


  mousedown: (e) ->
    e.stopPropagation()
    @composer.mousemove(e)
    #switch e.which
      #when 1 # Left button
        #@trigger 'mousedown', e

  #mouseup: (e) ->
    #e.stopPropagation()
    #@trigger 'mouseup', e

  mousemove: (e) ->
    e.stopPropagation()
    @composer.mousemove(e)

  #click: (e) ->
    #e.stopPropagation()
    #@trigger 'click', e


  hideCursor: ->
    console.log "Hide Cursor"
    @$el.css
      cursor: 'none'

  showCursor: ->
    console.log "Show Cursor"
    @$el.css
      cursor: ''

  changeCursor: (cursor) ->
    @$el.css cursor: cursor
