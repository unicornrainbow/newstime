class @Newstime.GroupView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'group-view'

    @propertiesView = new Newstime.GroupPropertiesView(target: this, model: @model)

  render: ->
    @$el.css
      top: @model.get('top') + @pageOffsetTop
      left: @model.get('left') + @pageOffsetLeft
    @$el.css _.pick @model.attributes, 'width', 'height'

  getPropertiesView: ->
    @propertiesView
