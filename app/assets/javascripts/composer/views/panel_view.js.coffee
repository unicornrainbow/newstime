class @Newstime.PanelView extends @Newstime.View

  events:
   'mousedown .title-bar': 'beginDrag'
   'mouseup .title-bar': 'endDrag'
   'mouseout': 'mouseout'
   'mousemove': 'dOMMousemove'
   'keydown': 'keydown'
   'paste': 'paste'
   'mousedown .dismiss': 'dismiss'

  initialize: (options) ->
    @$el.addClass('newstime-palette-view')

    @composer = Newstime.composer

    @model ?= new Newstime.Panel

    @$el.html """
      <div class="title-bar">
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
      </div>
    """

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')

    @initializePanel()

    @bindUIEvents()

    @listenTo @model, 'change', @render

    @render()

  render: ->
    @$el.css @model.pick('width', 'height')
    @renderPanel() if @renderPanel

  dismiss: (e) ->
    #@trigger 'dismiss'
    #@composer.panelLayerView.hoveredObject.trigger 'mouseout', e
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

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

    @composer.lockScroll()

    # Disengage capture layer to decieve mouse events directly.
    @composer.captureLayerView.disengage()


  mouseout: (e) ->
    # Only honer if mousing out to parent
    if e.toElement == @el.parentNode
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

  mousemove: (e) ->
    e.y += @composer.panelLayerView.topOffset

    if @tracking
      @$el.css('bottom', $(window).height() - event.y - @bottomMouseOffset)
      @$el.css('right', $(window).width() - event.x - @rightMouseOffset)

  mouseup: (e) ->
    if @tracking
      @tracking = false
      @trigger 'tracking-release', this
      @composer.popCursor()
      @mouseover(e)
      @endDrag()


  beginDrag: (e) ->
    if e.target == @$titleBar[0]
      @dragging = true
      @$titleBar.addClass('grabbing')

      # Calulate offsets
      @bottomMouseOffset = $(window).height() - event.clientY - parseInt(@$el.css('bottom'))
      @rightMouseOffset =  $(window).width() - event.clientX - parseInt(@$el.css('right'))

      # Engage and begin tracking here.

      @tracking = true
      @composer.pushCursor('-webkit-grabbing')
      @trigger 'tracking', this
      @composer.captureLayerView.engage()

  endDrag: (e) ->
    if @dragging
      @dragging = false
      @$titleBar.removeClass('grabbing')

  # Attachs html or element to body of palette
  attach: (html) ->
    @$body.html(html)

  setPosition: (bottom, right) ->
    #@$el.css(top: top, left: left)
    @$el.css(bottom: bottom, right: right)

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    #parseInt(@$el.css('left'))
    #@$el[0].offsetLeft
    #Math.round(@$el.position().left)
    #Math.round(
    Math.round(@$el.offset().left)
    #@$el[0].getBoundingClientRect()


  y: ->
    @$el[0].offsetTop

  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  clear: ->
    @$body.empty()
