# Newstime View, based on Backbone.View
class @Newstime.View extends Backbone.View

  # Binds standard UI Events
  bindUIEvents: ->
    @bind _.pick(this, uiEvents)

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
