#= require ../views/window_view

class @Newstime.EditTextAreaWindowView extends @Newstime.WindowView

  initializeWindow: (options) ->
    @$el.addClass 'edit-text-area-window'

    @textAreaContentItem = options.textAreaContentItem
    console.log @textAreaContentItem

    @model.set(width: 450, height: 500)

    @setPosition(50, 200)

    @$body.html """
      <textarea></textarea>
    """

    @$textarea = @$('textarea')

    @$textarea.css
      width: 450
      height: 500 - 22

    @$textarea.val(@textAreaContentItem.get('text'))
