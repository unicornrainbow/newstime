@Newstime = @Newstime || {}

class @Newstime.PropertiesPanelView extends Backbone.View

  events:
   'mousedown .title-bar': 'beginDrag'
   'mouseup .title-bar': 'endDrag'

  initialize: (options) ->
    @$el.hide()
    @$el.addClass('newstime-properties-panel')
    @$el.addClass('newstime-palette-view')

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
    @bind 'mouseout',  @mouseout

  dismiss: ->
    @trigger 'dismiss'
    @hide()

  mouseover: ->
    @hovered = true
    @$el.addClass 'hovered'

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @hovered = false
    @$el.removeClass 'hovered'

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e
      @hoveredObject = null

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
