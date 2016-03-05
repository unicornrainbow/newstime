class @Newstime.PanelView extends @Newstime.View

  events:
   'mousedown .title-bar': 'beginDrag'
   'mousedown .resize-scrub': 'beginResizeDrag'
   'mousemove': 'dOMMousemove'
   'keydown': 'keydown'
   'paste': 'paste'
   'mousedown .dismiss': 'dismiss'
   'mousedown': 'mousedown'
   'click': 'click'

  initialize: (options) ->
    @$el.addClass('newstime-palette-view')

    @composer = Newstime.composer
    @panelLayerView = @composer.panelLayerView

    @model ?= new Newstime.Panel

    @$el.html """
      <div class="title-bar">
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
      </div>
      <span class="resize-scrub"></span>
    """

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')
    @$resizeScrub = @$el.find('.resize-scrub')

    @initializePanel(options)

    @bindUIEvents()

    @listenTo @model, 'change', @render

    @render()


  mousedown: ->
    @panelLayerView.bringToFront(this)

  render: ->
    @$el.css @model.pick('width', 'height', 'top', 'left')
    @$el.css 'z-index': @model.get('z_index')
    @renderPanel() if @renderPanel

  dismiss: (e) ->
    @hide()
    @composer.panelLayerView.hoveredObject = null

    @hovered = false
    @$el.removeClass 'hovered'

    @composer.captureLayerView.engage()
    @composer.unlockScroll()


  keydown: (e) ->
    e.stopPropagation() #

    switch e.keyCode
      when 27 #ESC
        # Send focus back to composer.
        @composer.focus()
      when 83 # s
        if e.altKey
          e.preventDefault()
          @composer.edition.save()


  paste: (e) ->
    e.stopPropagation()


  mouseover: (e) =>
    @hovered = true
    @$el.addClass 'hovered'

    # Make foremost

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

    @composer.lockScroll()

    # Disengage capture layer to decieve mouse events directly.
    @composer.captureLayerView.disengage()


  mouseout: (e) =>
    @hovered = false
    @$el.removeClass 'hovered'

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null

    @composer.captureLayerView.engage()
    @composer.unlockScroll()

  dOMMousemove: (e) ->
    e.stopPropagation()

  hide: ->
    @hidden = true
    @$el.hide()

  show: ->
    @hidden = false
    @$el.show()

  toggle: ->
    if @hidden then @show() else @hide()


  mousemove: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    y += @composer.panelLayerView.topOffset

    if @tracking
      if @dragging
        @move(x, y)

      if @resizing
        @resize(x, y)
        ## Calculate correct resize values
        ##@$el.css('bottom', $(window).height() - e.y - @bottomMouseOffset)
        ##@$el.css('right', $(window).width() - e.x - @rightMouseOffset)

        ##console.log e.y - @topOffset  + @bottomMouseOffset
        #console.log @topOffset
        #@model.set
          #height: e.y - @topOffset  + @topMouseOffset
          #width:  e.x - @leftOffset + @leftMouseOffset



  move: (x, y) ->
    x -= @leftMouseOffset
    y -= @topMouseOffset

    @model.set
      left: x
      top: y


  resize: (x, y) ->
    @model.set
      width: x - @model.get('left') + @rightMouseOffset
      height: y - @model.get('top') + @bottomMouseOffset

  mouseup: (e) ->
    if @tracking
      @tracking = false
      @trigger 'tracking-release', this

      if @dragging
        @composer.popCursor()
        @mouseover(e)
        @endDrag()

      if @resizing
        @mouseover(e)
        @endResizeDrag()


  beginDrag: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    if e.target == @$titleBar[0]
      @dragging = true
      @$titleBar.addClass('grabbing')

      @leftMouseOffset = x - @model.get('left')
      @topMouseOffset = y - @model.get('top')

      # Engage and begin tracking here.

      @tracking = true
      @composer.pushCursor('-webkit-grabbing')
      @trigger 'tracking', this
      @composer.captureLayerView.engage()

  endDrag: (e) ->
    if @dragging
      @dragging = false
      @$titleBar.removeClass('grabbing')

  beginResizeDrag: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    if e.target == @$resizeScrub[0]
      @resizing = true

      # Calulate offsets
      @leftMouseOffset = x - @model.get('left')
      @topMouseOffset = y - @model.get('top')
      @rightMouseOffset = @model.get('width') - @leftMouseOffset
      @bottomMouseOffset = @model.get('height') - @topMouseOffset

      # Engage and begin tracking here.

      @tracking = true
      @trigger 'tracking', this
      @composer.captureLayerView.engage()

  endResizeDrag: (e) ->
    if @resizing
      @resizing = false

  # Attachs html or element to body of palette
  attach: (html) ->
    @$body.html(html)

  setPosition: (bottom, right) ->
    @model.set
      top: $(window).height() - bottom - @model.get('height')
      left: $(window).width() - right - @model.get('width')
    #@$el.css(top: top, left: left)
    #@$el.css(bottom: bottom, right: right)

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    @model.get('left')

  y: ->
    @model.get('top')

  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  clear: ->
    @$body.empty()

  click: (e) ->
    # Stop porpagation of clicks so the do not reach the panel view layer, which would rengage the capture view layer.
    e.stopPropagation()

  setZIndex: (index) ->
    @model.set 'z_index', index

  # Reset panel to default state.
  reset: ->
    @hovered = false
    @$el.removeClass 'hovered'
