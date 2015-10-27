#= require ../views/panel_view

class @Newstime.TextEditorPanelView extends @Newstime.WindowView

  initializePanel: ->
    @$el.addClass 'text-editor-panel'


    @model.set(width: 450, height: 500)

    @$body.html """
      <textarea></textarea>
    """

    @$textarea = @$('textarea')

    @$textarea.css
      width: 450
      height: 500 - 22
