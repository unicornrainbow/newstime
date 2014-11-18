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
    @originX = x
    @originY = y
    @trigger("tracking", this)

  mousemove: (e) ->
    if e.x < @originX
      left = e.x
      width = @originX - e.x
    else
      left = @originX
      width = e.x - @model.get('left')

    if e.y < @originY
      top = e.y
      height = @originY - e.y
    else
      top = @originY
      height = e.y - @model.get('top')

    @model.set
      left: left
      width: width
      top: top
      height: height

  mouseup: (e) ->
    @trigger("tracking-release", this)
    @remove() # Mostly for effect for the time being, immediatly removing the view.
