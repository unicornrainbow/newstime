#= require ../views/window_view

class @Newstime.EditTextAreaWindowView extends @Newstime.WindowView


  initializeWindow: (options) ->

    _.extend @events,
      'click .bold-btn': 'clickMakeBold'
      'click .italic-btn': 'clickMakeItalic'
      'click .link-btn': 'clickMakeLink'
      'mousedown .resize-scrub': 'beginResizeDrag'


    @$el.addClass 'edit-text-area-window'

    @textAreaContentItem = options.textAreaContentItem

    @model.set(width: 450, height: 500)

    @setPosition(50, 200)

    @$body.html """
      <div class="buttons">
        <button class="bold-btn">Bold</button><button class="italic-btn">Italic</button><button class="link-btn">Link</button>
        <button class="pull-right">Update</button>
      </div>
      <textarea></textarea>
      <span class="resize-scrub"></span>
    """

    @$textarea = @$('textarea')

    @$textarea.css
      width: 450
      height: 500 - 45

    @$textarea.val(@textAreaContentItem.get('text'))


  renderPanel: ->
    @$el.css @model.pick('top', 'left')
    @$textarea.css
      width: @model.get('width')
      height: @model.get('height') - 45


  setPosition: (top, left) ->
    @model.set(top: top, left: left)

  beginResizeDrag: (e) ->
      @resizing = true

      # TODO: Fix for mozilla (.clientX/Y)
      # TODO: Drive position from model

      x = e.x || e.clientX
      y = e.y || e.clientY


      @widthMouseOffset = @model.get('left') + @model.get('width') - x
      @heightMouseOffset = @model.get('top') + @model.get('height') - y


      # Engage and begin tracking here.

      @tracking = true
      @trigger 'tracking', this
      @composer.captureLayerView.engage()


  mousemove: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    y += @composer.panelLayerView.topOffset

    if @tracking
      if @dragging
        @move(x, y)

      if @resizing
        width = x + @widthMouseOffset - @model.get('left')
        height = y + @heightMouseOffset - @model.get('top')
        @resize(width, height)


  mouseup: (e) ->
    if @tracking
      @tracking = false
      @trigger 'tracking-release', this
      @composer.popCursor()
      @mouseover(e)
      @endDrag()

    if @resizing
      @resizing = false


  resize: (width, height) ->
    @model.set(width: width, height: height)

  clickMakeBold: ->
    textrange = @$textarea.textrange('get')
    @$textarea.textrange('replace', "**#{textrange.text}**")
    @$textarea.textrange('set', textrange.start + 2, textrange.length)

  clickMakeItalic: ->
    textrange = @$textarea.textrange('get')
    @$textarea.textrange('replace', "*#{textrange.text}*")
    @$textarea.textrange('set', textrange.start + 1, textrange.length)

  clickMakeLink: ->
    textrange = @$textarea.textrange('get')
    @$textarea.textrange('replace', "[#{textrange.text}]()")
    @$textarea.textrange('setcursor', textrange.end + 3)
