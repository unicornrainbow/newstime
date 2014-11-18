#= require ./canvas_item_view

class @Newstime.Selection extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-view'
    @vent = Newstime.composer.vent
    @model = new Backbone.Model()
    @model.bind 'change', @modelChanged, this

    @bind 'mousemove', @mousemove, this
    @bind 'mouseup', @mouseup, this

  modelChanged: ->
    @$el.css _.pick @model.changedAttributes(), 'top', 'left', 'width', 'height'

  beginSelection: (x, y) -> # TODO: rename beginDraw
    @model.set(left: x, top: y)
    @vent.trigger("tracking", this)

  mousemove: (e) ->
    @model.set
      width: e.x - @model.get('left')
      height: e.y - @model.get('top')

  mouseup: (e) ->
    @vent.trigger("tracking-release", this)
