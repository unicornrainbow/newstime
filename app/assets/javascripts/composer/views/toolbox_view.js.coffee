@Newstime = @Newstime || {}

class @Newstime.ToolboxView extends Backbone.View

  initialize: (options) ->
    @$el.hide()
    @$el.addClass('newstime-toolbox')

    @$el.html """
      <div class="title-bar">
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
      </div>
    """

    @composer = options.composer

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')

    # Create and attach buttons to the body.
    @selectToolButton =
      new Newstime.ToolboxButtonView
        type: 'select-tool'

    @textToolButton =
      new Newstime.ToolboxButtonView
        type: 'text-tool'

    @$body.append @selectToolButton.el
    @$body.append @textToolButton.el

    # Listen for model changes
    @model.bind 'change', @modelChanged, this

    # Bind mouse events
    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout
    @bind 'mousedown', @mousedown
    @bind 'mousemove', @mousemove
    @bind 'mouseup',   @mouseup

  modelChanged: ->
    @$el.css _.pick @model.changedAttributes(), 'top', 'left'

  # This is will be called by the application, if a mousedown event is targeted
  # at the panel
  mousedown: (e) ->
    @adjustEventXY(e)

    if e.y < 25 # Consider less than 25 y a title bar hit for now
      @beginDrag(e)

  mouseup: (e) ->
    if @moving
      @moving = false
      @trigger 'tracking-release', this

  mouseover: ->
    @hovered = true
    @$el.addClass 'hovered'
    #@composer.changeCursor('-webkit-grab')

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: ->
    @hovered = false
    @$el.removeClass 'hovered'
    #@composer.changeCursor('-webkit-grab') # Need to clear cursor

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e
      @hoveredObject = null


  dismiss: ->
    @trigger 'dismiss'
    @hide()

  hide: ->
    @$el.hide()

  show: ->
    @$el.show()

  #moveHandeler: (e) =>
    #@$el.css('top', event.pageY + @topMouseOffset)
    #@$el.css('left', event.pageX + @leftMouseOffset)

  beginDrag: (e) ->
    #@$titleBar.addClass('grabbing')
    #@composer.changeCursor('-webkit-grabbing')


    # Calulate offsets
    #@topMouseOffset = parseInt(@$el.css('top')) - event.pageY
    #@leftMouseOffset = parseInt(@$el.css('left')) - event.pageX

    @moving   = true

    @leftMouseOffset = e.x
    @topMouseOffset = e.y

    @trigger 'tracking', this

    #$(document).bind('mousemove', @moveHandeler)

  endDrag: (e) ->
    @$titleBar.removeClass('grabbing')
    $(document).unbind('mousemove', @moveHandeler)

  adjustEventXY: (e) ->
    e.x -= @x()
    e.y -= @y()

  mousemove: (e) ->
    if @moving
      @move(e.x, e.y)

  move: (x, y) ->
    x -= @leftMouseOffset
    y -= @topMouseOffset
    @model.set
      left: x
      top: y
    #@$el.css
      #left: x
      #top: y


  # Attachs html or element to body of palette
  attach: (html) ->
    @$body.html(html)

  setPosition: (top, left) ->
    @$el.css(top: top, left: left)

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    parseInt(@$el.css('left'))

  y: ->
    parseInt(@$el.css('top'))

  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()
