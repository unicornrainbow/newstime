class @Newstime.TextAreaEditorView extends Newstime.CanvasItemView

  events:
    dblclick: 'dblclick'

  initialize: (options) ->
    @$el.addClass 'text-area-editor'

  dblclick: ->
    console.log 'click'

  show: ->
    @$el.show()
