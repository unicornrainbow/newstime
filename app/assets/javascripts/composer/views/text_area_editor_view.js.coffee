class @Newstime.TextAreaEditorView extends Newstime.CanvasItemView

  events:
    'focus textarea': 'focusTextArea'
    'blur textarea': 'blurTextArea'

  initialize: (options) ->
    @$el.addClass 'text-area-editor'
    @composer = options.composer

    @bind 'keydown', @keydown

    @$el.html """
      <textarea class="basic-textarea">Hello</textarea>
    """

    # Is the editor visibly displayed?
    @hide()
    @visible = false

  keydown: (e) ->
    switch e.keyCode
      when 27 # ESC
        @hide()

  focusTextArea: ->
    @composer.blur()

  blurTextArea: ->
    @composer.focus()

  show: ->
    @visible = true

    unless @focused
      @focused = true
      @composer.pushFocus(this)

    @composer.lockScroll()
    @$el.show()

  hide: ->
    @visible = false

    if @focused
      @focused = false
      @composer.popFocus()

    @$el.hide()
    @composer.unlockScroll()

  hit: (x, y) ->
    return false # Above capture layer, so don't need mouse events from composer.

  mousedown: (e) ->
    @hide()
