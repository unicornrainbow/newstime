
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
    btnSize = @spnrSize * 50/195

    @$el.css width: @spnrSize, height: @spnrSize
    @$centerDot.css
      width: @spnrSize * 70/195
      height: @spnrSize * 70/195
      margin: "#{@spnrSize * 62.5/195}px auto"

    @$btns.css
      width: btnSize
      height: btnSize

    btnDeg = 64
    x = Math.cos(btnDeg/(180/Math.PI))
    y = Math.sin(btnDeg/(180/Math.PI))

    btnDistance = @spnrSize * 64/195 # from center


    x = @spnrSize/2 + btnDistance * x - btnSize/2
    y = @spnrSize/2 - btnDistance * y - btnSize/2

    @$headlineBtn.css top: y, left: x

    btnDeg = btnDeg - 51.5
    x = Math.cos(btnDeg/(180/Math.PI))
    y = Math.sin(btnDeg/(180/Math.PI))

    x = @spnrSize/2 + btnDistance * x - btnSize/2
    y = @spnrSize/2 - btnDistance * y - btnSize/2

    @$storyBtn.css top: y, left: x

    @bindUIEvents()

    @model.set
      left:0# -79
      top: 150

    @listenTo @model, 'change', @render

    @render()

  render: ->
    @$el.css @model.pick('top', 'left')


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
    touchVector = (getVector x y)

    # Are we in the center dot?
    if inCenterDot?(touchVector)
      # Start move
    else
      # Must be in the outer ring.


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
