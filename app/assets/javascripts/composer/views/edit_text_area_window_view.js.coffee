#= require ../views/window_view

class @Newstime.EditTextAreaWindowView extends @Newstime.WindowView


  initializeWindow: (options) ->

    _.extend @events,
      'click .bold-btn': 'clickMakeBold'
      'click .italic-btn': 'clickMakeItalic'
      'click .link-btn': 'clickMakeLink'


    @$el.addClass 'edit-text-area-window'

    @textAreaContentItem = options.textAreaContentItem
    console.log @textAreaContentItem

    @model.set(width: 450, height: 500)

    @setPosition(50, 200)

    @$body.html """
      <div class="buttons">
        <button class="bold-btn">Bold</button>
        <button class="italic-btn">Italic</button>
        <button class="link-btn">Link</button>
        <button class="pull-right">Update</button>
      </div>
      <textarea></textarea>
    """

    @$textarea = @$('textarea')

    @$textarea.css
      width: 450
      height: 500 - 45

    @$textarea.val(@textAreaContentItem.get('text'))


  clickMakeBold: ->
    text = @$textarea.textrange('get', 'text')
    @$textarea.textrange('replace', "**#{text}**")

  clickMakeItalic: ->
    text = @$textarea.textrange('get', 'text')
    @$textarea.textrange('replace', "*#{text}*")

  clickMakeLink: ->
    textrange = @$textarea.textrange('get')
    @$textarea.textrange('replace', "[#{textrange.text}]()")
    @$textarea.textrange('setcursor', textrange.end + 3)
