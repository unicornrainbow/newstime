class @Newstime.MenuView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-view"

    @$el.html """
      <div class="container">
        #{JST["composer/templates/newstime_logo"]()}
        <span class="menu-title">Edition</span>
        <span class="menu-title">Section</span>
        <span class="menu-title">View</span>
      </div>
    """

    offset = @$el.offset()
    @leftOffset = 0


    @$menuTitles = @$('.menu-title')
    @$container = @$('.container')

    @bindUIEvents()

    @bind 'attach', @handelAttach
    @bind 'windowResize', @handelWindowResize

  mousemove: (e) ->
    e = @getMappedEvent(e)
    #console.log e

  handelAttach: ->
    @updateOffset()

  handelWindowResize: ->
    @updateOffset()

  updateOffset: ->
    offset = @$container.offset()
    @leftOffset = offset.left

  # Coverts external to internal coordinates.
  mapExternalCoords: (x, y) ->
    x -= @leftOffset

    return [x, y]

  # Returns a wrapper event with external coords mapped to internal.
  # Note: Wrapping the event prevents modifying coordinates on the orginal
  # event. Stop propagation and prevent are called through to the wrapped event.
  getMappedEvent: (event) ->
    event = new Newstime.Event(event)
    [event.x, event.y] = @mapExternalCoords(event.x, event.y)
    return event
