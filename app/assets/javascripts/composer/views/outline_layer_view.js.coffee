class @Newstime.OutlineLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'outline-layer-view'

    @outlineViews = []

    @composer = options.composer

    @listenTo @composer, 'zoom', @zoom


  zoom: ->
    @zoomLevel = @composer.zoomLevel
    @computeZoomedPosition()
    @render()

  # Computes and sets the zoomed position.
  computeZoomedPosition: ->
    position = _.clone(@position)

    # Apply zoom
    if @zoomLevel
      rawHeight = position.height
      rawWidth = position.width

      position.height = rawHeight*@zoomLevel
      position.width = rawWidth*@zoomLevel

      position.left -= (position.width - rawWidth)/2.0

    @zoomedPosition = position


  setPosition: (position) ->
    @position = position
    @computeZoomedPosition()
    @render()

  render: ->
    @$el.css @zoomedPosition
    _.each @outlineViews, (view) -> view.render()

  attach: (outlineView) ->
    @outlineViews.push(outlineView)
    @$el.append(outlineView.el)
