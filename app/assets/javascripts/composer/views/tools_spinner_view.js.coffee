
class @Dreamtool.ToolsSpinnerView extends Newstime.View

  initialize: (options) ->
    @$el.addClass 'tools-spinner'

    @$el.html """
      <div class="center-dot"></div>
      <button class="tool headline-tool"></button>
      <button class="tool story-tool"></button>
    """

    @model = new Backbone.Model

    @composer = options.composer

    @$centerDot   =   @$('.center-dot')
    @$headlineBtn  =   @$('.headline-tool')
    @$storyBtn    =   @$('.story-tool')
    @$btns  =  @$('button')

    @spnrSize = 175 # spinnerSize
    @btnSize = @spnrSize * 50/195


    @$el.css width: @spnrSize, height: @spnrSize

    @centerDotSize = @spnrSize * 70/195
    @centerDotRadius = @centerDotSize/2
    @centerDotMargin = (@spnrSize - @centerDotSize)/2
    @$centerDot.css
      width: @centerDotSize
      height: @centerDotSize
      margin: "#{@centerDotMargin}px auto"

    @$btns.css
      width: @btnSize
      height: @btnSize

    @bindUIEvents()

    @model.set
      left:0# -79
      top: 150
      angle: 0

    @listenTo @model, 'change', @render

    @render()

  render: ->
    @$el.css @model.pick('top', 'left')

    btnDeg = 64 + @model.get('angle')
    x = Math.cos(btnDeg/(180/Math.PI))
    y = Math.sin(btnDeg/(180/Math.PI))

    btnDistance = @spnrSize * 64/195 # from center

    x = @spnrSize/2 + btnDistance * x - @btnSize/2
    y = @spnrSize/2 - btnDistance * y - @btnSize/2

    @$headlineBtn.css top: y, left: x

    btnDeg = btnDeg - 51.5
    x = Math.cos(btnDeg/(180/Math.PI))
    y = Math.sin(btnDeg/(180/Math.PI))

    x = @spnrSize/2 + btnDistance * x - @btnSize/2
    y = @spnrSize/2 - btnDistance * y - @btnSize/2

    @$storyBtn.css top: y, left: x


  hit: (x, y) ->
    left = @model.get('left')
    top  = @model.get('top')

    a = x-(left+@spnrSize/2)
    b = y-(top+@spnrSize/2)
    hitRadius = Math.sqrt(a**2+b**2)

    hitRadius <= @spnrSize/2
    # Math.atan2(y, x)
    # true | false

  touchstart: (e) ->
    # alert 'yum'
    x = e.touches[0].x
    y = e.touches[0].y
    # console.log e.touches[0]

    left = @model.get('left')
    top  = @model.get('top')
    # In terms of the circle
    x = x-(left+@spnrSize/2)
    y = y-(top+@spnrSize/2)

    touchVector = @getVector(x, y)

    # Are we in the center dot?
    if touchVector[1] <= @centerDotRadius
      @beginDrag(e)
    else
      # @beginSpin(touchVector)
      # Begin spin
      @speed = 0
      clearInterval(@spinInterval) if @spinInterval

      # Reset angle
      if @model.get('angle') > 360
        @model.set('angle', @model.get('angle')%360)

      @spinning = true
      @spinAngleOffset = touchVector[0] - @model.get('angle')
      @trigger 'tracking', this

      # alert touchVector[0]

      # Must be in the outer ring.
      # find the radius from the center point to the touch center.

  touchmove: (e) ->
    x = e.touches[0].x
    y = e.touches[0].y

    if @moving
      @move(x, y)

    else if @spinning
      left = @model.get('left')
      top  = @model.get('top')
      # In terms of the circle
      x = x-(left+@spnrSize/2)
      y = y-(top+@spnrSize/2)

      touchVector = @getVector(x, y)

      if touchVector[1] <= @spnrSize/2
        angle = touchVector[0] - @spinAngleOffset
        @speed = angle - @model.get('angle')
        if @speed > 180
          @speed = @speed - 360

        else if @speed < -180
          @speed = @speed + 360

        @model.set('angle', angle)
      else
        @letGo()

    else
      if @hit(x, y)
        left = @model.get('left')
        top  = @model.get('top')
        # In terms of the circle
        x = x-(left+@spnrSize/2)
        y = y-(top+@spnrSize/2)

        touchVector = @getVector(x, y)

        if touchVector[1] > @centerDotRadius
          # Begin spin
          @spinning = true
          @spinAngleOffset = touchVector[0] - @model.get('angle')

  letGo: ->
    @spinning = false
    speed = @speed * 2
    return if speed is 0

    angle = @model.get('angle')
    start = Date.now()
    duration = 27 * Math.abs(@speed/50)
    model = @model

    @spinInterval = id = setInterval ->
      t = (Date.now() - start)/(duration * 1000)
      # console.log (speed * duration*10) * (1-(1-t)*(1-t))
      # console.log 1-(1-t)*(1-t)

      # speed
      # scrollTop - (1-t) * speed

      model.set 'angle', angle + (speed * duration*10) * (1-(1-t)*(1-t))

      clearInterval(id) if t > 1
    , 22

  touchend: (e) ->
    if @moving
      @moving = false

    if @spinning
      @letGo()

    @trigger 'tracking-release', this

  move: (x, y) ->
    x -= @leftDragOffset
    y -= @topDragOffset

    x = Math.max(x, -75)
    y = Math.max(y, -75)

    @model.set
      left: x
      top: y


  getVector: (x, y) ->
    # Angle
    angle = -Math.atan2(y, x) * 180/Math.PI
    angle += 360 if angle < 0

    # Distance
    distance = Math.sqrt(x**2+y**2)

    [angle, distance]


  beginDrag: (e) ->
    @moving   = true

    @leftDragOffset = e.touches[0].x - @model.get('left')
    @topDragOffset = e.touches[0].y - @model.get('top')

    @trigger 'tracking', this

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
