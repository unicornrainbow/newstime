# ## Libraries
#= require lib/zepto
#= require lib/underscore
#= require lib/backbone
#= require lib/backbone-relational
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
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')
    @canvas = $('.page')[0]

    ## Config
    @topOffset = 62 # px

    # Create application layers
    @coverLayerView = new Newstime.CoverLayerView
      composer: this
      topOffset: @topOffset
    @$body.append(@coverLayerView.el)

    @panelLayerView = new Newstime.PanelLayerView
      composer: this
      topOffset: @topOffset
    @$body.append(@panelLayerView.el)

    @canvasLayerView = new Newstime.CanvasLayerView
      el: @canvas
      composer: this
      topOffset: @topOffset
    @$body.append(@canvasLayerView.el)


    @globalKeyboardDispatch = new Newstime.GlobalKeyboardDispatch
      composer: this

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

    @coverLayerView.bind 'mouseup', @mouseup, this
    @coverLayerView.bind 'mousemove', @mousemove, this
    @coverLayerView.bind 'mousedown', @mousedown, this

    @canvasLayerView.bind 'tracking',         @tracking, this
    @canvasLayerView.bind 'tracking-release', @trackingRelease, this

    #$("[headline-control]").headlineControl headlineProperties
    #storyPropertiesView = new Newstime.StoryPropertiesView()
    #$("[story-text-control]").each (i, el) ->
      #new Newstime.StoryTextControlView(
        #el: el
        #toolPalette: storyPropertiesView
      #)
      #return

    #contentRegionPropertiesView = new Newstime.ContentRegionPropertiesView()
    #$("[content-region-control]").each (i, el) ->
      #new Newstime.ContentRegionControlView(
        #el: el
        #propertiesView: contentRegionPropertiesView
      #)
      #return

    #photoPropertiesView = new Newstime.PhotoPropertiesView()
    #$("[photo-control]").each (i, el) ->
      #new Newstime.PhotoControlView(
        #el: el
        #propertiesView: photoPropertiesView
      #)
      #return

    #@gridOverlay = $(".grid-overlay").hide()

    ## Init panels
    @toolboxView = new Newstime.ToolboxView
      composer: this
    @panelLayerView.attachPanel(@toolboxView)
    @toolboxView.show()

    #@propertiresPanelView = new Newstime.PropertiesPanelView
      #composer: this
    #@panelLayerView.attachPanel(@propertiesPanelView)
    #@propertiesPanelView.show()

    @repositionScroll()

    # Events
    #$(window).scroll(@captureScrollPosition)

  tracking: (layer) ->
    @trackingLayer = layer


  trackingRelease: (layer) ->
    @trackingLayer = null


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


  # Public: Handles mousemove events, called by CoverLayerView
  mousemove: (e) ->

    # Store current cursor location.
    @mouseX = e.x
    @mouseY = e.y

    # Compistae for top offset to allow room for menu
    @mouseY -= @topOffset

    e =
      x: @mouseX
      y: @mouseY

    if @trackingLayer

      @trackingLayer.trigger 'mousemove', e
      return true

    hit = if @panelLayerView.hit(@mouseX, @mouseY)
      @panelLayerView
    else if @canvasLayerView.hit(@mouseX, @mouseY)
      @canvasLayerView

    if hit
      if @hitLayer != hit
        if @hitLayer
          @hitLayer.trigger 'mouseout', e
        @hitLayer = hit
        @hitLayer.trigger 'mouseover', e

    else
      if @hitLayer
        @hitLayer.trigger 'mouseout', e
        @hitLayer = null


    # Pass mousemove through to the hit layer
    if @hitLayer
      @hitLayer.trigger 'mousemove', e

      # Clear cursor state
      #@changeCursor('')

  mousedown: (e) ->
    e =
      x: @mouseX
      y: @mouseY


    if @trackingLayer
      # For the time being, block mousedowns while tracking
      return true

    # TODO: Rather than tracking an relying to the hovered object, we need to track
    # which if the layers gets the hit, and pass down to it for delegation to
    # the individual object.
    if @hitLayer
      @hitLayer.trigger 'mousedown', e


  mouseup: (e) ->

    e =
      x: @mouseX
      y: @mouseY

    if @trackingLayer
      @trackingLayer.trigger 'mouseup', e
      return true

    # TODO: Rather than tracking an relying to the hovered object, we need to track
    # which if the layers gets the hit, and pass down to it for delegation to
    # the individual object.
    if @hitLayer
      @hitLayer.trigger 'mouseup', e

  zoomIn: ->
    @canvasLayerView.zoomIn()

  zoomOut: ->
    @canvasLayerView.zoomOut()

  zoomInPoint: (x, y) ->
    @canvasLayerView.zoomInPoint(x, y)

  zoomToPoint: (x, y) ->
    @canvasLayerView.zoomToPoint(x, y)

  zoomReset: ->
    @canvasLayerView.zoomReset()

  repositionScroll: ->
    @canvasLayerView.repositionScroll()

$ ->
  Newstime.Composer.init()

  # For testing purposes
  edition_id = document.URL.match(/editions\/(\w*)/)[1] # Hack to get edition id from url string
  window.edition = new Newstime.Edition({_id: edition_id})
  edition.fetch()

  return
