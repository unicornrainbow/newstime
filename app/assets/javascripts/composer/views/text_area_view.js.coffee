#= require ./content_item_view

class @Newstime.TextAreaView extends Newstime.ContentItemView

  contentItemClassName: 'text-area-view'

  @getter 'uiLabel', ->
    "Text"

  initializeContentItem: ->

    @lineHeight = parseInt(Newstime.config.storyTextLineHeight)

    @bind 'paste', @paste
    @bind 'dblclick', @dblclick
    @bind 'resized', @reflow  # Reflow text on resize

    @listenTo @model, 'change:text', @reflow
    @listenTo @model, 'change:rendered_html', @clearNeedsReflow

    @render()


  setElement: (el) ->
    super
    @$el.addClass 'text-area-view'

  render: =>
    unless @needsReflow
      super
      @$el.html @model.get('rendered_html')

    else
      @$el.css @model.pick 'top', 'left'

  paste: (e) =>
    # Retreive pasted text. Not cross browser compliant. (Webkit)
    pastedText = e.originalEvent.clipboardData.getData('text/plain')

    @model.set 'text', pastedText

    # Now that we have the desired text, need to save this as the text with the
    # story text-content item, should that be our target. Also need to grab and
    # rerender the contents of the pasted text after it has been reflowed.

    @reflow()

  dblclick: (e) ->
    Newstime.composer.vent.trigger 'edit-text', @model

  keydown: (e) =>
    switch e.keyCode
      when 49 # 1
        unless e.altKey # Don't clash with zoom 1,2,3
          @model.set('columns', 1)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      when 50 # 2
        unless e.altKey
          @model.set('columns', 2)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      when 51 # 3
        unless e.altKey
          @model.set('columns', 3)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      else
        super(e)

  dragBottom: (x, y) ->
    geometry = @getGeometry()
    height = @pageView.snapBottom(y) - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      height: height

  dragBottomLeft: (x, y) ->
    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()
    snapLeft = @pageView.snapLeft(x)
    if snapLeft
      x = snapLeft
      @composer.drawVerticalSnapLine(snapLeft)

    y = @pageView.snapBottom(y)

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: height

  dragBottomRight: (x, y) ->
    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()
    width = x - geometry.left
    y = @pageView.snapBottom(y)

    snapRight = @pageView.snapRight(width)
    if snapRight
      @composer.drawVerticalSnapLine(snapRight + geometry.left)
      width = snapRight

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      width: width
      height: height

  reflow: ->
    @model.reflow()

  clearNeedsReflow: ->
    @needsReflow = false

  _createModel: ->
    @edition.contentItems.add({_type: 'TextAreaContentItem'})

  _createPropertiesView: ->
    new Newstime.TextAreaPropertiesView(target: this, model: @model)
