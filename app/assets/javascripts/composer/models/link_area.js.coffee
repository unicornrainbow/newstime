class @Newstime.LinkArea
  _.extend @prototype, Backbone.Events

  constructor: (link, options={}) ->
    @$link = $(link)
    @topOffset = options.topOffset || 0
    @composer = options.composer

    # Get area
    @position = @$link.offset()
    @top = @position.top - @topOffset
    @left = @position.left
    @width = @$link.width()
    @height = @$link.height()

    @bind 'mousedown' , @mousedown
    @bind 'mouseover' , @mouseover
    @bind 'mouseout'  , @mouseout


  # Detects a hit of the selection
  hit: (x, y) ->
    ## Detect if corrds lie within the geometry
    @left <= x <= @left + @width &&
      @top <= y <= @top + @height

  mousedown: (e) ->
    window.location = @$link.attr('href')

  mouseover: (e) ->
    @composer.pushCursor('pointer')
    #@$link.addClass 'hover'

  mouseout: (e) ->
    @composer.popCursor()
    #@$link.removeClass 'hover'
