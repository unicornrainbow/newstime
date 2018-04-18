@Dreamtool ?= {}

# Newstime View, based on Backbone.View
class View extends Backbone.View

  # Delegate method calls to another object on this,
  # ala Ruby delegate.
  #
  # methods - Method names to map to object
  # to - Object on this to map methods *to*
  @delegate = (methods, to, prefix='') ->
    _.each methods, (m) =>
      @::[prefix + m] = (attrs...) ->
        @[to][m](attrs...)

  # Binds standard UI Events
  bindUIEvents: ->
    @bind _.pick(this, uiEvents)


  # Localize some jQuery methods
  $methods = ['html', 'append',
    'addClass', 'toggleClass']
  @delegate $methods, '$el', '$'


uiEvents = ['mouseover',
            'mouseout',
            'mousedown',
            'mouseup',
            'mousemove',
            'keydown',
            'click',
            'dblclick',
            'paste',
            'contextmenu',
            'windowresize',
            'touchstart',
            'touchmove',
            'touchend',
            'touchcancel',
            'tap',
            'doubletap',
            'press']


Newstime.View = View
Dreamtool.View = View
