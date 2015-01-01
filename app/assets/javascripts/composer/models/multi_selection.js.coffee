class @Newstime.MultiSelection
  _.extend @prototype, Backbone.Events

  constructor: (options={}) ->
    @models = []

  getPropertiesView: ->
    null # TODO: Create a propeties panel view

  deactivate: ->

  destroy: ->

  # Add a model, and assocaited view to the multiselection.
  add: (model) ->
    @models.push model
    @trigger 'change'

  getPosition: ->
    top = @models[0].get('top')
    left = @models[0].get('left')
    bottom = 0
    right = 0

    _.each @models, (model) ->
      top = Math.min(model.get('top'), top)
      left  = Math.min(model.get('left'), left)
      bottom = Math.max(model.get('top') + model.get('height'), bottom)
      right = Math.max(model.get('left') + model.get('width'), right)

    position =
      top: top
      left: left
      height: bottom - top
      width: right - left

    position
