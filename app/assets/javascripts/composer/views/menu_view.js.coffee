class @Newstime.MenuView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-view"

    @composer = Newstime.composer

    @leftOffset = 0
    @attachedMenuTitles = []

    @$el.html JST["composer/templates/menu_view"](this)

    @$menuTitles = @$('.menu-title')
    @$container = @$('.container')

    @editionTitleView = new Newstime.EditionMenuView
    @attachMenuTitle(@editionTitleView)

    @sectionTitleView = new Newstime.SectionMenuView
    @attachMenuTitle(@sectionTitleView)

    @viewTitleView = @composer.viewMenu = new Newstime.ViewMenuView
    @attachMenuTitle(@viewTitleView)

    #@helpTitleView = new Newstime.HelpMenuView
    #@attachMenuTitle(@helpTitleView)

    #@previewMenuView = new Newstime.PreviewMenuView
    #@attachMenuTitle(@previewMenuView)

    @bindUIEvents()

    @bind 'attach', @handelAttach
    @bind 'windowResize', @handelWindowResize

  mousemove: (e) ->
    e = @getMappedEvent(e)

    hover = null

    unless hover
      if @composer.selectedMenu
         if @composer.selectedMenu.menuBody.boundry.hit(e.x, e.y)
            hover = @composer.selectedMenu.menuBody

      unless hover
        # NOTE: Would be nice to skip active selection here, since already
        # checked, but no biggie.
        _.find @attachedMenuTitles, (menuTitleView) ->
          if menuTitleView.boundry.hit(e.x, e.y)
            hover = menuTitleView

    if hover
      if @hoveredObject != hover
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
        @hoveredObject = hover
        @hoveredObject.trigger 'mouseover', e
    else
      if @hoveredObject
        @hoveredObject.trigger 'mouseout', e
        @hoveredObject = null

    if @hoveredObject
      @hoveredObject.trigger 'mousemove', e

  mouseover: (e) ->
    @hovered = true
    e = @getMappedEvent(e)
    @pushCursor() # Replace with hover stack implementation eventually
    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @hovered = false
    e = @getMappedEvent(e)
    @popCursor()
    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null

  mousedown: (e) ->
    e = @getMappedEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'mousedown', e
    else
      @composer.selectedMenu.close() if @composer.selectedMenu

  pushCursor: ->
    @composer.pushCursor(@getCursor())

  popCursor: ->
    @composer.popCursor()

  getCursor: ->
    'default'

  handelAttach: ->
    @updateOffset()

  handelWindowResize: ->
    @updateOffset()

  attachMenuTitle: (menuTitleView) ->
    @attachedMenuTitles.push(menuTitleView)
    @$container.append(menuTitleView.el)
    @$container.append(menuTitleView.menuBody.el)
    menuTitleView.parent = this
    menuTitleView.trigger 'attach'

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
