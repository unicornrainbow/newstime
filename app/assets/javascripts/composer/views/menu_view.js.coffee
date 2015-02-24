class @Newstime.MenuView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-view"

    @leftOffset = 0

    @$el.html JST["composer/templates/menu_view"](this)

    @$menuTitles = @$('.menu-title')
    @$container = @$('.container')


    @editionTitleView = new Newstime.MenuTitleView(title: "Edition")
    @attachMenuTitle(@editionTitleView)

    @sectionTitleView = new Newstime.MenuTitleView(title: "Section")
    @attachMenuTitle(@sectionTitleView)

    @viewTitleView = new Newstime.MenuTitleView(title: "View")
    @attachMenuTitle(@viewTitleView)


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

  attachMenuTitle: (menuTitleView) ->
    @$container.append(menuTitleView.el)

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
