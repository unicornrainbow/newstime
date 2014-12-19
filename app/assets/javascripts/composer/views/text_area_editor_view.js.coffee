class @Newstime.TextAreaEditorView extends Newstime.CanvasItemView

  events:
    dblclick: 'dblclick'

  initialize: (options) ->
    @$el.addClass 'text-area-editor'
    @composer = options.composer


    # Is the editor visibly displayed?
    @hide()
    @visible = false

  dblclick: ->
    @hide()

  show: ->
    @visible = true
    #@composer.lockScroll()
    @$el.show()

  hide: ->
    @visible = false
    @$el.hide()
    #@composer.unlockScroll()

  hit: (x, y) ->
    return false unless @visible

    return true

    #return false # TODO: Implement me.

  mousedown: (e) ->
    @hide()
