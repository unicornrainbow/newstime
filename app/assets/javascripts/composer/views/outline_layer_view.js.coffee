class @Newstime.OutlineLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'outline-layer-view'

    @outlineViews = []

    @composer = options.composer

    @composer.bind 'zoom', @zoom, this


  zoom: ->
    @zoomLevel = @composer.zoomLevel
    @render()

    # Recalulate a position the containing div.
    #
    # Render all outline views.

  setPosition: (position) ->
    @position = position
    @render()

  render: ->
    _position = _.clone(@position)

    # Apply zoom
    if @zoomLevel
      rawHeight = _position.height
      rawWidth = _position.width

      _position.height = rawHeight*@zoomLevel
      _position.width = rawWidth*@zoomLevel

      _position.left -= (_position.width - rawWidth)/2


    @$el.css _position

    _.each @outlineViews, (view) -> view.render()

  attach: (outlineView) ->
    @outlineViews.push(outlineView)
    @$el.append(outlineView.el)
