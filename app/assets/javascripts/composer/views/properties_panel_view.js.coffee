@Newstime = @Newstime || {}

class @Newstime.PropertiesPanelView extends Backbone.View

  events:
   'mousedown .title-bar': 'beginDrag'
   'mouseup .title-bar': 'endDrag'
   'mouseout': 'mouseout'
   'keydown': 'keydown'


  initialize: (options) ->
    @$el.hide()
    @$el.addClass('newstime-properties-panel')
    @$el.addClass('newstime-palette-view')

    @composer = options.composer

    @$el.html """
      <div class="title-bar">
      </div>
      <div class="palette-body">
      </div>
    """

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')

    # Attach to dom
    $('body').append(@el)

    @bind 'mouseover', @mouseover

  dismiss: ->
    @trigger 'dismiss'
    @hide()

  keydown: (e) ->
    e.stopPropagation() #

    switch e.keyCode
      when 27 #ESC
        # Send focus back to composer.
        @composer.focus()



  mouseover: (e) =>
    @hovered = true
    @$el.addClass 'hovered'

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

    # Disengage capture layer to decieve mouse events directly.
    @composer.captureLayerView.disengage()


  mouseout: (e) ->
    # Only honer if mousing out to parent
    if e.toElement == @el.parentNode
      @hovered = false
      @$el.removeClass 'hovered'

      if @hoveredObject
        @hoveredObject.trigger 'mouseover', e
        @hoveredObject = null

      @composer.captureLayerView.engage()

  hide: ->
    @$el.hide()

  show: ->
    @$el.show()

  moveHandeler: (e) =>
    @$el.css('top', event.pageY + @topMouseOffset)
    @$el.css('left', event.pageX + @leftMouseOffset)

  beginDrag: (e) ->
    @$titleBar.addClass('grabbing')

    # Calulate offsets
    @topMouseOffset = parseInt(@$el.css('top')) - event.pageY
    @leftMouseOffset = parseInt(@$el.css('left')) - event.pageX

    $(document).bind('mousemove', @moveHandeler)

  endDrag: (e) ->
    @$titleBar.removeClass('grabbing')
    $(document).unbind('mousemove', @moveHandeler)

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

  #x: ->
    #parseInt(@$el.css('left'))

  #y: ->
    #parseInt(@$el.css('top'))


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

  mount: (propertiesView) ->
    @$body.html propertiesView.el

  clear: ->
    @$body.empty()
