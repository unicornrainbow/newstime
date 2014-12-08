class @Newstime.ContentItemOutlineView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'content-item-outline-view'

    @pageOffsetLeft = options.pageOffsetLeft
    @pageOffsetTop  = options.pageOffsetTop

    @$el.css
      top: @model.get('top') + @pageOffsetTop
      left: @model.get('left') + @pageOffsetLeft
    @$el.css _.pick @model.attributes, 'width', 'height'

    @model.bind 'change', @modelChanged, this

  modelChanged: ->
    @$el.css
      top: @model.get('top') + @pageOffsetTop
      left: @model.get('left') + @pageOffsetLeft
    @$el.css _.pick @model.attributes, 'width', 'height'

  show: ->
    @$el.addClass 'outline'

  hide: ->
    @$el.removeClass 'outline'
