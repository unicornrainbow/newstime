# Covers and capture mouse events for relay to interested objects.
class @Newstime.VerticalSnapLine extends Backbone.View

  initialize: (options) ->
    @$el.addClass "vertical-snap-line"

  show: ->
    @$el.show()

  hide: ->
    @$el.hide()

  set: (left) ->
    @$el.css left: left
