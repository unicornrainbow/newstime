class @Newstime.ToolboxView extends Backbone.View

  initialize: (options) ->
    @$el.hide()
    @$el.addClass('newstime-toolbox')

    @$el.html """
      <div class="title-bar">
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
      </div>
    """

    @composer = options.composer

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')

    # Create and attach buttons to the body.

    @buttons = []
    @buttons.push new Newstime.ToolboxButtonView
      type: 'select-tool'
      toolbox: @model
      position: { top: '24px', left: '2px' }

    @buttons.push new Newstime.ToolboxButtonView
      type: 'headline-tool'
      toolbox: @model
      position: { top: '24px', left: '34px' }

    @buttons.push new Newstime.ToolboxButtonView
      type: 'type-tool'
      toolbox: @model
      position: { top: '56px', left: '2px' }

    @buttons.push new Newstime.ToolboxButtonView
      type: 'photo-tool'
      toolbox: @model
      position: { top: '56px', left: '34px' }

    @buttons.push new Newstime.ToolboxButtonView
      type: 'video-tool'
      toolbox: @model
      position: { top: '88px', left: '2px' }

    #_.each @buttons, (button) =>
      #button.bind 'select', @selectButton, this

    @$body.append _.map @buttons, (view) -> view.el

    # Listen for model changes
    @model.bind 'change', @modelChanged, this
    #@model.bind 'change:selectedTool', @selectedToolChanged, this

    # Bind mouse events
    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout
    @bind 'mousedown', @mousedown
    @bind 'mousemove', @mousemove
    @bind 'mouseup',   @mouseup

  #selectButton: (button) ->
    #@selectedButton.deselect() if @selectedButton
    #@selectedButton = button

  modelChanged: ->
    @$el.css _.pick @model.changedAttributes(), 'top', 'left'

  # This is will be called by the application, if a mousedown event is targeted
  # at the panel
  mousedown: (e) ->
    @adjustEventXY(e)

    if e.y < 25 # Consider less than 25 y a title bar hit for now
      @beginDrag(e)

    else if @hoveredObject
      @hoveredObject.trigger 'mousedown', e

  mouseup: (e) ->

    if @moving
      @composer.popCursor()
      @moving = false
      @trigger 'tracking-release', this

  mouseover: ->
    @hovered = true
    @$el.addClass 'hovered'

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @hovered = false
    @$el.removeClass 'hovered'

    if @overTitle
      @overTitle = false
      @composer.popCursor()

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null


  dismiss: ->
    @trigger 'dismiss'
    @hide()

  hide: ->
    @$el.hide()

  show: ->
    @$el.show()


  beginDrag: (e) ->
    @composer.pushCursor('-webkit-grabbing')

    @moving   = true

    @leftMouseOffset = e.x
    @topMouseOffset = e.y

    @trigger 'tracking', this

    #$(document).bind('mousemove', @moveHandeler)

  endDrag: (e) ->
    $(document).unbind('mousemove', @moveHandeler)

  adjustEventXY: (e) ->
    e.x -= @x()
    e.y -= @y()

  mousemove: (e) ->


    if @moving
      @move(e.x, e.y)
    else
      # Detect a button hit
      @adjustEventXY(e)

      if e.y < 25 # Consider less than 25 y a title bar hit for now
        unless @overTitle
          @overTitle = true
          @composer.pushCursor('-webkit-grab')
      else
        if @overTitle
          @overTitle = false
          @composer.popCursor()

      # Check for hit inorder to highlight hovered button
      if @hoveredObject # Check active button first.
        button = @hoveredObject if @hoveredObject.hit(e.x, e.y)

      unless button
        # NOTE: Would be nice to skip active button here, since already
        # checked, but no biggie.
        button = _.find @buttons, (button) ->
          button.hit(e.x, e.y)

      if @hovered # Only process events if hovered.
        if button
          if @hoveredObject != button
            if @hoveredObject
              @hoveredObject.trigger 'mouseout', e
            @hoveredObject = button
            @hoveredObject.trigger 'mouseover', e

          return true
        else
          if @hoveredObject
            @hoveredObject.trigger 'mouseout', e
            @hoveredObject = null

          return false

      else
        # Defer processing of events until we are declared the hovered object.
        @hoveredObject = button
        return true

  move: (x, y) ->
    x -= @leftMouseOffset
    y -= @topMouseOffset

    x = Math.max(x, -2)
    y = Math.max(y, -2)

    @model.set
      left: x
      top: y


  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    parseInt(@$el.css('left'))

  y: ->
    parseInt(@$el.css('top'))

  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()
