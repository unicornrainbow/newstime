class @Newstime.GroupSelection
  _.extend @prototype, Backbone.Events

  constructor: (options={}) ->
    @group = options.group
    @groupView = options.groupView

  getPropertiesView: ->
    @groupView.getPropertiesView()

  deactivate: ->
    @groupView.deactivate()

  destroy: ->

  convertToMultiSelection: ->
    multiSelection = new Newstime.MultiSelection()
    multiSelection.add(@group)
    multiSelection
