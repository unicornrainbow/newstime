class @Newstime.TextAreaEditorView extends Newstime.CanvasItemView

  events:
    dblclick: 'dblclick'

  initialize: (options) ->
    @$el.addClass 'text-area-editor'
    @composer = options.composer

    @bind 'keydown', @keydown

    # Is the editor visibly displayed?
    @hide()
    @visible = false

  dblclick: ->
    @hide()

  keydown: (e) ->
    console.log e

  show: ->
    @visible = true

    unless @focused
      @focused = true
      @composer.pushFocus(this)

    #@composer.lockScroll()
    @$el.show()

  hide: ->
    @visible = false

    if @focused
      @focused = false
      @composer.popFocus()

    @$el.hide()
    #@composer.unlockScroll()

  hit: (x, y) ->
    return false # Above capture layer, so don't need mouse events from composer.

  mousedown: (e) ->
    @hide()
