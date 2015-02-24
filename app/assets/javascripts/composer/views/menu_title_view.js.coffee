class @Newstime.MenuTitleView extends Newstime.View

  tagName: 'span'

  initialize: (options) ->
    @$el.addClass "menu-title"

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
    @$el.addClass 'hover'

  mouseout: ->
    @$el.removeClass 'hover'

  mousedown: (e) ->
    console.log "Clicked #{@title}"
