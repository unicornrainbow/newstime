#= require ../views/window_view

class @Newstime.EditTextAreaWindowView extends @Newstime.WindowView

  initializePanel: ->
    @$el.addClass 'edit-text-area-window'

    @model.set(width: 450, height: 500)

    @setPosition(50, 200)

    @$body.html """
      <textarea></textarea>
    """

    @$textarea = @$('textarea')

    @$textarea.css
      width: 450
      height: 500 - 22
