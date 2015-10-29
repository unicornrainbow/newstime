#= require ../views/panel_view

class @Newstime.WindowView extends @Newstime.PanelView

  initializePanel: (options) ->
    @initializeWindow(options) if @initializeWindow

  setPosition: (top, left) ->
    @$el.css(top: top, left: left)

  beginDrag: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    if e.target == @$titleBar[0]
      @dragging = true
      @$titleBar.addClass('grabbing')

      @leftMouseOffset = x - parseInt(@$el.css('left'))
      @topMouseOffset = y - parseInt(@$el.css('top'))

      # Engage and begin tracking here.

      @tracking = true
      @composer.pushCursor('-webkit-grabbing')
      @trigger 'tracking', this
      @composer.captureLayerView.engage()


  mousemove: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    y += @composer.panelLayerView.topOffset

    if @tracking && @dragging
      @move(x, y)


  move: (x, y) ->
    x -= @leftMouseOffset
    y -= @topMouseOffset

    @$el.css('left', x)
    @$el.css('top', y)

  toggle: ->
    if @hidden
      @show()
    else
      @hide()
