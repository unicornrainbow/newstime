
# Newstime View, based on Backbone.View
class @Newstime.View extends Backbone.View

  # Bind mouse events
  bindMouseEvents: ->
    mouseEvents = ['mouseover', 'mouseout', 'mousedown', 'mouseup', 'mousemove']
    mouseEvents = _.pick(this, mouseEvents)
    @bind(mouseEvents)
