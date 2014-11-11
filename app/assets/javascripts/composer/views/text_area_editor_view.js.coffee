class @Newstime.TextAreaEditorView extends Newstime.CanvasItemView

  initialize: (options) ->
    @$el.addClass 'text-area-editor'

  show: ->
    @$el.show()
