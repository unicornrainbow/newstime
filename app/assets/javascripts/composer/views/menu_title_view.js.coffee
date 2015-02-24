class @Newstime.MenuTitleView extends Newstime.View

  tagName: 'span'

  initialize: (options) ->
    @$el.addClass "menu-title"

    @composer = Newstime.composer

    @title = options.title

    @$el.html(@title)

    @listenToOnce Newstime.composer.vent, 'ready', @measureBoundry

    @bindUIEvents()

  measureBoundry: ->
    position = @$el.position()
    @left   = position.left
    @top    = position.top
    @height = @$el.height()
    @width  = @$el.width()

    @boundry = new Newstime.Boundry _.pick this, 'top', 'left', 'height', 'width'

  mouseover: ->
    if @composer.selectedMenu && @composer.selectedMenu != this
      @open()

    @$el.addClass 'hover'

  mouseout: ->
    @$el.removeClass 'hover'

  mousedown: (e) ->
    @open()

  close: ->
    @_open = false
    @$el.removeClass 'open'
    @composer.selectedMenu = null
    @composer.popFocus()

  open: ->
    if @composer.selectedMenu
      @composer.selectedMenu.close()

    @composer.selectedMenu = this
    @composer.pushFocus(this)
    @_open = true
    @$el.addClass 'open'

  keydown: (e) =>
    switch e.keyCode
      when 27 # ESC
        @close()
