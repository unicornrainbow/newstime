@Newstime = @Newstime || {}

class @Newstime.ToolboxButtonView extends Backbone.View
  initialize: (options) ->
    @type = options.type

    @$el.addClass "toolbox-button"
    @$el.addClass @type

    @$el.css options.position

    @geometry =
      top: parseInt(options.position.top)
      left: parseInt(options.position.left)
      height: 30
      width: 30

    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout


  # Detects a hit of the selection
  hit: (x, y) ->
    geometry = @getGeometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 2 # 2px
    geometry.top -= buffer
    geometry.left -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    geometry.left <= x <= geometry.left + geometry.width &&
      geometry.top <= y <= geometry.top + geometry.height


  getGeometry: ->
    _.pick @geometry , 'top', 'left', 'width', 'height'

  mouseover: (e) ->
    @hovered = true
    @$el.addClass 'hovered'

  mouseout: (e) ->
    @hovered = false
    @$el.removeClass 'hovered'
