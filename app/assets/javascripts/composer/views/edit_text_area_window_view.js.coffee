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
    @$textarea.css
      width: @model.get('width')
      height: @model.get('height') - 45

  beginResizeDrag: (e) ->
      @resizing = true

      # TODO: Fix for mozilla (.clientX/Y)
      # TODO: Drive position from model


      @widthMouseOffset = parseInt(@$el.css('left')) + @model.get('width') - e.x
      @heightMouseOffset = parseInt(@$el.css('top')) + @model.get('height') - e.y


      # Engage and begin tracking here.

      @tracking = true
      @trigger 'tracking', this
      @composer.captureLayerView.engage()


  mousemove: (e) ->
    e.y += @composer.panelLayerView.topOffset

    if @tracking
      if @dragging
        @move(e.x, e.y)

      if @resizing
        width = e.x + @widthMouseOffset - parseInt(@$el.css('left'))
        height = e.y + @heightMouseOffset - parseInt(@$el.css('top'))
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
    text = @$textarea.textrange('get', 'text')
    @$textarea.textrange('replace', "**#{text}**")

  clickMakeItalic: ->
    text = @$textarea.textrange('get', 'text')
    @$textarea.textrange('replace', "*#{text}*")

  clickMakeLink: ->
    textrange = @$textarea.textrange('get')
    @$textarea.textrange('replace', "[#{textrange.text}]()")
    @$textarea.textrange('setcursor', textrange.end + 3)
