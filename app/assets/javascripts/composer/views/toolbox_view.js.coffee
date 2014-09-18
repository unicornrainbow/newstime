@Newstime = @Newstime || {}

class @Newstime.ToolboxView extends Backbone.View

  events:
   'mouseup .title-bar': 'endDrag'
   'click .dismiss': 'dismiss'
   #'mousedown .title-bar': 'beginDrag'

  initialize: (options) ->
    @$el.hide()
    @$el.addClass('newstime-toolbox')

    @$el.html """
      <div class="title-bar">
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
        <div class="toolbox-button select-tool"></div>
        <div class="toolbox-button"></div>
        <div class="toolbox-button"></div>
      </div>
    """

    @composer = options.composer

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')

    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout
    @bind 'mousedown', @mousedown
    @bind 'mousemove', @mousemove
    @bind 'mouseup',   @mouseup

    # Attach to dom
    #$('body').append(@el)

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
    #
    #


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

  mouseover: ->
    @$el.addClass 'hovered'
    #@composer.changeCursor('-webkit-grab')

  mouseout: ->
    @$el.removeClass 'hovered'
    #@composer.changeCursor('-webkit-grab') # Need to clear cursor

  adjustEventXY: (e) ->
    e.x -= @x()
    e.y -= @y()

  mousemove: (e) ->
    if @moving
      @move(e.x, e.y)

  move: (x, y) ->
    x -= @leftMouseOffset
    y -= @topMouseOffset
    @$el.css
      left: x
      top: y


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
