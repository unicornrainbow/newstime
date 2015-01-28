class @Newstime.MultiSelection
  _.extend @prototype, Backbone.Events

  constructor: (options={}) ->
    @models = []
    @page = null

  deactivate: ->

  destroy: ->

  # Add a model, and assocaited view to the multiselection.
  add: (view) ->
    @models.push view.model
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

    # TODO: Use top, left, bottom, right for bounding boxes.
    # Create Bounding box class.

    # And expended position bounding box used for hit detection.
    @expandedPosition = @addBuffer(@position, 4)

  # Detects a hit of the selection
  hit: (x, y) ->
    @hitsBoundingBox(@expandedPosition, x, y)

  # Expand the bounding box by buffer distance in each direction to extend
  # clickable area.
  addBuffer: (box, buffer) ->
    box = _.clone(box)

    box.top -= buffer
    box.left -= buffer
    box.width += buffer*2
    box.height += buffer*2

    box

  hitsBoundingBox: (box, x, y) ->
    ## Detect if corrds lie within the geometry
    box.left <= x <= box.left + box.width &&
      box.top <= y <= box.top + box.height

  setSizeAndPosition: (value) ->
    _.each @models, (model) =>
      topOffset = model.get('top') - @position.top
      leftOffset = model.get('left') - @position.left

      model.set
        top: value.top + topOffset
        left: value.left + leftOffset
    @calculatePosition()
    @trigger 'change'
    # TODO: Update size and position
