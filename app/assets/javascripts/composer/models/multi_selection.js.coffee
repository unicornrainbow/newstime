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
