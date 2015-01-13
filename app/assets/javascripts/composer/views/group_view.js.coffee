class @Newstime.GroupView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'group-view'

    @propertiesView = new Newstime.GroupPropertiesView(target: this, model: @model)

    @pageOffsetTop = options.pageOffsetTop
    @pageOffsetLeft = options.pageOffsetLeft

    @outlineView = options.outlineView

    @composer = options.composer

    @bind
      mouseover: @mouseover
      mouseout: @mouseout

  render: ->
    @$el.css
      top: @model.get('top') + @pageOffsetTop
      left: @model.get('left') + @pageOffsetLeft
    @$el.css _.pick @model.attributes, 'width', 'height'

  measurePosition: ->
    @contentItems = @model.getContentItems()
    first = _.first(@contentItems)
    boundry =  first.getBoundry()

    top = boundry.top
    left = boundry.left
    bottom = boundry.bottom
    right = boundry.right

    _.each @contentItems, (contentItem) ->
      boundry = contentItem.getBoundry()

      top = Math.min(top, boundry.top)
      left = Math.min(left, boundry.left)
      bottom = Math.max(bottom, boundry.bottom)
      right = Math.max(right, boundry.right)

    boundry = new Newstime.Boundry(top: top, left: left, bottom: bottom, right: right)
    @model.set _.pick boundry, 'top', 'left', 'width', 'height'


  getPropertiesView: ->
    @propertiesView

  # Detects a hit of the selection
  hit: (x, y) ->
    x = x - @pageOffsetLeft
    y = y - @pageOffsetTop

    geometry = @getGeometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    geometry.top -= buffer
    geometry.left -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    geometry.left <= x <= geometry.left + geometry.width &&
      geometry.top <= y <= geometry.top + geometry.height


  getGeometry: ->
    @model.pick('top', 'left', 'height', 'width')


  mouseover: (e) ->
    @hovered = true
    @outlineView.show()
    @composer.pushCursor @getCursor()


  getCursor: ->
    'default'


  mouseout: (e) ->
    @adjustEventXY(e)

    if @hoveredHandle
      @hoveredHandle.trigger 'mouseout', e
      @hoveredHandle = null

    @hovered = false
    @outlineView.hide()
    @composer.popCursor()


  adjustEventXY: (e) ->
    # Apply page offset
    e.x -= @pageOffsetLeft
    e.y -= @pageOffsetTop
