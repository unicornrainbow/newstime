#= require ./canvas_item_view

class @Newstime.HeadlineView extends Newstime.CanvasItemView

  initialize: (options) ->
    super
    @composer = options.composer

    @$el.addClass 'headline-view'

    @placeholder = "Type Headline" # Text to show when there is no headline
    @fontWeights = Newstime.config.headlineFontWeights

    ## Bind View Events
    @bind 'dblclick',  @dblclick

    @propertiesView = new Newstime.HeadlineProperties2View(target: this)

    @render()

  render: ->
    @$el.css
      top: @model.get('top') + @pageOffsetTop
      left: @model.get('left') + @pageOffsetLeft

    @$el.css _.pick @model.changedAttributes(), 'margin-top', 'margin-right', 'margin-bottom', 'margin-left'
    @$el.css 'font-size': @model.get('font_size')
    @$el.css 'font-weight': @model.get('font_weight')

    @$el.css _.pick @model.changedAttributes(),
    if !!@model.get('text')
      spanWrapped = _.map @model.get('text'), (char) ->
        if char == '\n'
          char = "<br>"
        "<span>#{char}</span>"
      spanWrapped= spanWrapped.join('')
      @$el.html(spanWrapped)
      @$el.removeClass 'placeholder'
    else
      @$el.text(@placeholder)
      @$el.addClass 'placeholder'


  destroy: ->
    super()
    @$headlineEl.remove() if @$headlineEl?

  deactivate: ->
    @clearEditMode()
    super()

  keydown: (e) =>
    if @editMode
      switch e.keyCode
        when 8 # del
          e.stopPropagation()
          e.preventDefault()
          @model.backspace()
          @fitToBorderBox()
        when 27 # ESC
          e.stopPropagation()
          e.preventDefault()
          @clearEditMode()
        when 37 # left arrow
          @moveCursorLeft()
          e.stopPropagation()
          e.preventDefault()
        when 39 # right arrow
          @moveCursorRight()
          e.stopPropagation()
          e.preventDefault()
        else
          unless e.ctrlKey || e.altKey # Skip ctrl and alt
            char = @getEventChar(e)
            if char?
              e.stopPropagation()
              e.preventDefault()
              @model.typeCharacter(char)

          @fitToBorderBox()

    else
      switch e.keyCode
        when 13 # Enter
          @startEditMode()
        when 187 # +
          unless e.altKey
            @increaseFontWeight()
        when 189 # -
          unless e.altKey
            @decreaseFontWeight()
        when 84 # t
          # Trim excess margin from top and bottom
          @trimVerticalMargin()
        when 70 # f
          # Fits the headline to match with with zero margins
          @fit()
        else
          super(e)

  increaseFontWeight: ->
    if @model.get('font_weight')
      # Find current font weight
      fontWeight = parseInt(@model.get('font_weight'))

      index = _.indexOf(@fontWeights, fontWeight)

      fontWeight = @fontWeights[index+1] if index < @fontWeights.length

      @model.set('font_weight', fontWeight)
    else
      @model.set('font_weight', @$headlineEl.css('font-weight'))

    @fitToBorderBox()

  decreaseFontWeight: ->
    if @model.get('font_weight')
      # Find current font weight
      fontWeight = parseInt(@model.get('font_weight'))

      index = _.indexOf(@fontWeights, fontWeight)

      fontWeight = @fontWeights[index-1] if index > 0

      @model.set('font_weight', fontWeight)
    else
      @model.set('font_weight', @$headlineEl.css('font-weight'))

    @fitToBorderBox()

  increaseFont: ->
    if @model.get('font_size')
      @model.set('font_size', parseInt(@model.get('font_size')) + 1 + "px")
    else
      @model.set('font_size', @$headlineEl.css('font-size'))

  decreaseFont: ->
    if @model.get('font_size')
      @model.set('font_size', parseInt(@model.get('font_size')) - 1 + "px")
    else
      @model.set('font_size', @$headlineEl.css('font-size'))

  moveCursorLeft: ->
    if @model.get('cursorPosition')?
      @model.set('cursorPosition', Math.max(@model.get('cursorPosition') - 1, 0))
    else
      @model.set('cursorPosition', @model.get('text').length - 1)


  moveCursorRight: ->
    if @model.get('cursorPosition')?
      @model.set('cursorPosition', Math.min(@model.get('cursorPosition')+1, @model.get('text').length))
    else
      @model.get('cursorPosition', @model.get('text').length)

  dblclick: ->
    @startEditMode()

  startEditMode: ->
    @$el.addClass 'edit-mode'
    @editMode = true

  clearEditMode: ->
    @$el.removeClass 'edit-mode'
    @editMode = false

  trimVerticalMargin: ->
    headlineHeight = @$headlineEl.height()
    @model.set
      height: headlineHeight
      'margin-top': 0
      'margin-bottom': 0

  # Fits headline to vertical width, vertical margins.
  fit: ->
    headlineHeight = @$headlineEl.height()
    height = @$el.height()

    if headlineHeight < height
      @model.set
        height: headlineHeight
        'margin-top': 0
        'margin-bottom': 0
    else
      headlineWidth  = @$headlineEl.width()
      width = @$el.width()
      fontSize = parseInt(@$headlineEl.css('font-size'))
      fontSize *= width/headlineWidth
      @model.set
        'font_size': fontSize + 'px',
        'margin-left': 0
        'margin-right': 0
        'margin-top': 0
        'margin-bottom': 0

      @model.set height: @$headlineEl.height()


  dragTop: (x, y) ->
    super
    @fitToBorderBox()

  dragRight: (x, y) ->
    super
    @fitToBorderBox()

  dragBottom: (x, y) ->
    super
    @fitToBorderBox()

  dragLeft: (x, y) ->
    super
    @fitToBorderBox()

  dragTopLeft: (x, y) ->
    super
    @fitToBorderBox()

  dragTopRight: (x, y) ->
    super
    @fitToBorderBox()

  dragBottomLeft: (x, y) ->
    super
    @fitToBorderBox()

  dragBottomRight: (x, y) ->
    super
    @fitToBorderBox()

  fitToBorderBox: ->
    if @$headlineEl
      # Get the width and height of the headline element.
      headlineWidth  = @$headlineEl.width()
      headlineHeight = @$headlineEl.height()

      width = @$el.width()
      height = @$el.height()

      fontSize = parseInt(@$headlineEl.css('font-size'))

      if width/height > headlineWidth/headlineHeight
        # Match Height
        fontSize *= height/headlineHeight
        @model.set('font_size', fontSize + 'px')
      else
        # Match Width
        fontSize *= width/headlineWidth
        @model.set('font_size', fontSize + 'px')

      # Compute and set margins
      headlineWidth  = @$headlineEl.width()
      headlineHeight = @$headlineEl.height()

      verticalMargin = (height - headlineHeight)/2 + 'px'
      horizontalMargin = (width - headlineWidth)/2 + 'px'

      @model.set
        'margin-top': verticalMargin
        'margin-right': horizontalMargin
        'margin-bottom': verticalMargin
        'margin-left': horizontalMargin
