class @Newstime.TextAreaEditorView extends Newstime.CanvasItemView

  events:
    dblclick: 'dblclick'

  initialize: (options) ->
    @$el.addClass 'text-area-editor'

    # Is the editor visibly displayed?
    @visible = false

  dblclick: ->
    @hide()

  show: ->
    @visible = true
    @$el.show()

  hide: ->
    @visible = false
    @$el.hide()

  hit: (x, y) ->
    return false unless @visible

    return true

    #return false # TODO: Implement me.

  mousedown: (e) ->
    @hide()
