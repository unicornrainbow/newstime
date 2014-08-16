# ## Libraries
#= require lib/zepto
#= require lib/underscore
#= require lib/backbone
#= require faye
#
# ## App
#= require newstime_util
#= require_tree ./composer/plugins
#= require_tree ./composer/models
#= require_tree ./composer/views

@Newstime = @Newstime or {}

@Newstime.Composer =
  init: ->
    @captureAuthenticityToken()

    # Capture Elements
    @$body = $('body')

    ## Config
    @topOffset = 62 # px


    # Create application layers
    @coverLayerView = new Newstime.CoverLayerView
      composer: this
      topOffset: @topOffset
    @$body.append(@coverLayerView.el)

    @panelLayerView = new Newstime.PanelLayerView
      topOffset: @topOffset
    @$body.append(@panelLayerView.el)


    headlineProperties = new Newstime.HeadlinePropertiesView()

    @globalKeyboardDispatch = new Newstime.GlobalKeyboardDispatch() # Handler


    canvasDragView = new Newstime.CanvasDragView
      composer: this

    @globalKeyboardDispatch.bind 'dragModeEngaged', ->
      canvasDragView.engage()

    @globalKeyboardDispatch.bind 'dragModeDisengaged', ->
      canvasDragView.disengage()

    #@eventEmitter = new Newstime.EventEmitter (Mouse events, Keyboard Events,
    #Scroll Events)

    #var composerModals = $(".composer-modal"),
    #contentRegionModal = $(".add-content-region"),
    #contentItemModal = $(".add-content-item").contentModal();


    Newstime.Composer.globalKeyboardDispatch = @globalKeyboardDispatch
    Newstime.Composer.keyboard = new Newstime.Keyboard(defaultFocus: @globalKeyboardDispatch)
    #keyboard.pushFocus(textRegion) // example

    # Initialize Plugins
    $("#edition-toolbar").editionToolbar()
    $("#section-nav").sectionNav()
    $("[headline-control]").headlineControl headlineProperties
    storyPropertiesView = new Newstime.StoryPropertiesView()
    $("[story-text-control]").each (i, el) ->
      new Newstime.StoryTextControlView(
        el: el
        toolPalette: storyPropertiesView
      )
      return

    contentRegionPropertiesView = new Newstime.ContentRegionPropertiesView()
    $("[content-region-control]").each (i, el) ->
      new Newstime.ContentRegionControlView(
        el: el
        propertiesView: contentRegionPropertiesView
      )
      return

    photoPropertiesView = new Newstime.PhotoPropertiesView()
    $("[photo-control]").each (i, el) ->
      new Newstime.PhotoControlView(
        el: el
        propertiesView: photoPropertiesView
      )
      return

    $("[page-compose]").each (i, el) =>
      new Newstime.PageComposeView(
        el: el
        coverLayerView: @coverLayerView
      )
      return


    @gridOverlay = $(".grid-overlay").hide()

    #@toolboxView = new Newstime.ToolboxView
      #composer: this
    #@panelLayerView.attachPanel(@toolboxView)
    #@toolboxView.show()


    #@propertiresPanelView = new Newstime.PropertiesPanelView
      #composer: this
    #@panelLayerView.attachPanel(@propertiesPanelView)
    #@propertiesPanelView.show()


    #var zoomHandeler = new Newstime.ZoomHandler()
    #Newstime.Composer.zoomHandler = zoomHandeler
    ctrlZoomHandeler = new Newstime.CtrlZoomHandler()
    Newstime.Composer.ctrlZoomHandler = ctrlZoomHandeler

    # Wire Up events
    #@coverLayerView.bind 'mousedown', (e) =>
      #@mousedown(e)

    #@coverLayerView.bind 'mousemove', (e) =>
      #@mousemove(e)

  captureAuthenticityToken: ->
    @authenticityToken = $("input[name=authenticity_token]").first().val()
    return

  toggleGridOverlay: ->
    @gridOverlay.toggle()
    return

  hideCursor: ->
    @coverLayerView.hideCursor()

  showCursor: ->
    @coverLayerView.showCursor()

  changeCursor: (cursor) ->
    @coverLayerView.changeCursor(cursor)


  mousemove: (e) ->

    # Store current cursor location.
    @mouseX = e.x
    @mouseY = e.y - @topOffset

    e =
      x: @mouseX
      y: @mouseY

    # Check for a hit on panel layer
    hit = @panelLayerView.hit(e.x, e.y)


    # Check for hit on canvas layer
    #hit = @canvasLayerView.hit(e.x, e.y)


    if hit
      # Store as hoveredObject and trigger mouseout, mouseover events
      if @hoveredObject != hit
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', {}

        @hoveredObject = hit
        @hoveredObject.trigger 'mouseover', {}

    else

      # Clear hovered object, if there is one.
      if @hoveredObject
        @hoveredObject.trigger 'mouseout', {}
        @hoveredObject = null

      # Clear cursor state
      @changeCursor('')

  mousedown: (e) ->
    e =
      x: @mouseX
      y: @mouseY

    if @hoveredObject
      @hoveredObject.trigger 'mousedown'

$ ->
  Newstime.Composer.init()
  return
