class @Newstime.SelectionView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-view resizable'
    @selection = options.selection
    @composer = options.composer

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    # HACK: Shouldn't be binding direct to the content item model and view
    @contentItem = @selection.contentItem
    @contentItemView = @selection.contentItemView

    @pageOffsetLeft = @contentItemView.pageOffsetLeft
    @pageOffsetTop  = @contentItemView.pageOffsetTop

    @contentItem.bind 'change', @render, this

    @render()


  render: ->
    position = _.pick @contentItem.attributes, 'width', 'height'

    position.top = @contentItem.get('top')
    position.top += @pageOffsetTop

    position.left = @contentItem.get('left')
    position.left += @pageOffsetLeft

    # Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)
