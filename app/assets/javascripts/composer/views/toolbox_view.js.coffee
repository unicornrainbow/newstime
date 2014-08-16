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
      </div>
    """

    @composer = options.composer

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')

    @bind 'mouseover', @mouseover
    @bind 'mouseout', @mouseout

    # Attach to dom
    #$('body').append(@el)

  # This is will be called by the application, if a mousedown event is targeted
  # at the panel
  mousedown: (e) ->

    # Did it hit the title bar?
    titleBarHit = true # Pretend it did.

    if titleBarHit
      console.log "Begin Drag"
      @beginDrag()


  dismiss: ->
    @trigger 'dismiss'
    @hide()

  hide: ->
    @$el.hide()

  show: ->
    @$el.show()

  moveHandeler: (e) =>
    @$el.css('top', event.pageY + @topMouseOffset)
    @$el.css('left', event.pageX + @leftMouseOffset)

  beginDrag: (e) ->
    #@$titleBar.addClass('grabbing')
    @composer.changeCursor('-webkit-grabbing')


    # Calulate offsets
    @topMouseOffset = parseInt(@$el.css('top')) - event.pageY
    @leftMouseOffset = parseInt(@$el.css('left')) - event.pageX

    $(document).bind('mousemove', @moveHandeler)

  endDrag: (e) ->
    @$titleBar.removeClass('grabbing')
    $(document).unbind('mousemove', @moveHandeler)

  mouseover: ->
    @$el.addClass 'hovered'

  mouseout: ->
    @$el.removeClass 'hovered'

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
