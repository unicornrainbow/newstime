class @Newstime.SelectionView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-view resizable'
    @selection = options.selection

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

    @$el.css
      top: @contentItem.get('top') + @pageOffsetTop
      left: @contentItem.get('left') + @pageOffsetLeft
    @$el.css _.pick @contentItem.attributes, 'width', 'height'

    @contentItem.bind 'change', @modelChanged, this

  modelChanged: ->
    @$el.css
      top: @contentItem.get('top') + @pageOffsetTop
      left: @contentItem.get('left') + @pageOffsetLeft
    @$el.css _.pick @contentItem.attributes, 'width', 'height'
