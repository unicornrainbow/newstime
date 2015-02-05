#= require ../mixins/draggable
#
# CanvasItemView are CanvasItems which can appear on the canvas, or within a
# canvas like region like a group. Both ContentItemView and GroupViews are
# CanvasItemViews.
#
class @Newstime.CanvasItemView extends @Newstime.View
  @include Newstime.Draggable

  initialize: (options={}) ->
    @addClassNames()

    @composer ?= Newstime.composer
    @edition  ?= @composer.edition

    @model ?= @_createModel()

    @propertiesView ?= @_createPropertiesView()

    @outlineView = @composer.outlineViewCollection.add
                     model: @model

    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove

    @bindUIEvents()

    @initializeCanvasItem()

  addClassNames: ->
    @$el.addClass @className

  render: ->
    @$el.css @model.pick 'width', 'height', 'top', 'left', 'z-index'

  @getter 'top',  -> @model.get('top')
  @getter 'left', -> @model.get('left')
  @getter 'pageView', -> @_pageView

  @setter 'pageView', (value) ->
    @_pageView = value
    if value && value.model.id
      @model.set(page_id: value.model.id)

  getPropertiesView: ->
    @propertiesView

  select: (selectionView) ->
    unless @selected
      @selected = true
      @selectionView = selectionView

  deselect: ->
    if @selected
      @selected = false
      @selectionView = null
      @trigger 'deselect', this

  setSizeAndPosition: (attributes) ->
    @model.set(attributes)

  setElement: (el) ->
    super
    @addClassNames()

  # Sets model values.
  set: ->
    @model.set.apply(@model, arguments)


  # Detects a hit of the selection
  hit: (x, y) ->
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
