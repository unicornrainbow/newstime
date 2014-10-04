# Covers and capture mouse events for relay to interested objects.
class @Newstime.CoverLayerView extends Backbone.View

  events:
    'mousedown': 'mousedown'
    'mouseup': 'mouseup'
    'mousemove': 'mousemove'
    'mouseout': 'mouseout'
    'dblclick': 'dblclick'
    'click': 'click'
    'contextmenu': 'contextmenu'
    'click': 'click'

  initialize: (options) ->
    @$el.addClass "cover-layer-view"

    @topOffset = options.topOffset # Apply top offset (Allows room for menu)
    @composer = options.composer

    @$el.css top: "#{@topOffset}px"

  contextmenu: (e) ->
    @trigger "contextmenu", e

  mousedown: (e) ->
    e.stopPropagation()
    @trigger 'mousedown', e
    #switch e.which
      #when 1 # Left button
        #@trigger 'mousedown', e

  mouseup: (e) ->
    e.stopPropagation()
    @trigger 'mouseup', e

  mousemove: (e) ->
    e.stopPropagation()
    @trigger 'mousemove', e

  click: (e) ->
    e.stopPropagation()
    @trigger 'click', e

  dblclick: (e) ->
    e.stopPropagation()
    @trigger 'dblclick', e

  mouseout: (e) ->
    e.stopPropagation()
    @trigger 'mouseout', e

  hideCursor: ->
    @$el.css
      cursor: 'none'

  showCursor: ->
    @$el.css
      cursor: ''

  changeCursor: (cursor) ->
    @$el.css cursor: cursor
