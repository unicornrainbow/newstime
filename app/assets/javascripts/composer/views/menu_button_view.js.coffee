@Dreamtool ?= {}

class @Dreamtool.MenuButtonView extends Newstime.View

  tagName: 'button'

  initialize: (options={}) ->
    @$el.addClass "menu-button"

    @$el.html(options['text'])
    @click = options['click'] if options['click']

    @composer = Newstime.composer

    @listenToOnce Newstime.composer.vent, 'ready', @measureBoundry

    @bindUIEvents()

    @initializeButton() if @initializeButton?

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
    @$el.addClass 'pushed'

  mouseup: (e) ->
    @$el.removeClass 'pushed'
