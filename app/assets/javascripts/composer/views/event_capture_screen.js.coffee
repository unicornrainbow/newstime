# Covers and capture mouse events for relay to interested objects.
class @Newstime.EventCaptureScreen extends Backbone.View

  events:
    'mousedown': 'mousedown'
    'mouseup': 'mouseup'
    'mousemove': 'mousemove'
    'click': 'click'


  initialize: (options) ->
    @$el.addClass "event-capture-screen"
    $('body').append(@el)

  mousedown: (e) ->
    e.stopPropagation()
    @trigger 'mousedown', e

  mouseup: (e) ->
    e.stopPropagation()
    @trigger 'mouseup', e

  mousemove: (e) ->
    e.stopPropagation()
    @trigger 'mousemove', e

  click: (e) ->
    e.stopPropagation()
    @trigger 'click', e
