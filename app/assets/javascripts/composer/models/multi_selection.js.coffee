class @Newstime.MultiSelection
  _.extend @prototype, Backbone.Events

  constructor: (options={}) ->
    @models = []
    @page = null

  getPropertiesView: ->
    null # TODO: Create a propeties panel view

  deactivate: ->

  destroy: ->

  # Add a model, and assocaited view to the multiselection.
  add: (model) ->
    @models.push model
    @trigger 'change'

  getPosition: ->
    @calculatePosition()
    @position

  calculatePosition: ->
    top = @models[0].get('top')
    left = @models[0].get('left')
    bottom = 0
    right = 0

    _.each @models, (model) ->
      # TODO: Need to take into consideration page position
      page = model.getPage() # Need to have access to page offsets at the model
      pageOffsetTop  = page.get('offset_top') || 0
      pageOffsetLeft = page.get('offset_left') || 0

      top = Math.min(model.get('top') + pageOffsetTop, top)
      left  = Math.min(model.get('left') + pageOffsetLeft, left)
      bottom = Math.max(model.get('top') + model.get('height') + pageOffsetTop, bottom)
      right = Math.max(model.get('left') + model.get('width') + pageOffsetLeft, right)

    @position =
      top: top
      left: left
      height: bottom - top
      width: right - left

  # Detects a hit of the selection
  hit: (x, y) ->
    position = _.clone(@position)

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    position.top -= buffer
    position.left -= buffer
    position.width += buffer*2
    position.height += buffer*2

    ## Detect if corrds lie within the geometry
    position.left <= x <= position.left + position.width &&
      position.top <= y <= position.top + position.height
