#= require ./canvas_item_view

class @Newstime.TextAreaView extends Newstime.CanvasItemView

  initialize: (options) ->
    super

    @$el.addClass 'text-area-view'

    #@lineHeight = parseInt(Newstime.config.storyTextLineHeight)

    @bind 'paste', @paste
    #@bind 'dblclick',  @dblclick

    @bind 'resized', @reflow, this  # Reflow text on resize

    #@setContentEl(options.contentEl) if options.contentEl

    @propertiesView = new Newstime.TextAreaPropertiesView(target: this)

    @render()


  render: =>
    unless @needsReflow
      super

  destroy: ->
    super()
    @$contentEl.remove() if @$contentEl?

  paste: (e) =>
    # Retreive pasted text. Not cross browser compliant. (Webkit)
    pastedText = e.originalEvent.clipboardData.getData('text/plain')

    @model.set('text', pastedText)

    # Now that we have the desired text, need to save this as the text with the
    # story text-content item, should that be our target. Also need to grab and
    # rerender the contents of the pasted text after it has been reflowed.

    @reflow()

  dblclick: (e) ->
    Newstime.composer.vent.trigger 'edit-text', @model

  keydown: (e) =>
    switch e.keyCode
      when 49 # 1
        @model.set('columns', 1)
        @reflow()
        e.stopPropagation()
        e.preventDefault()
      when 50 # 2
        @model.set('columns', 2)
        @reflow()
        e.stopPropagation()
        e.preventDefault()
      when 51 # 3
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
    geometry = @getGeometry()
    x = @pageView.snapLeft(x)
    y = @pageView.snapBottom(y)

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: height

  dragBottomRight: (x, y) ->
    geometry = @getGeometry()
    width = @pageView.snapRight(x - geometry.left)
    y = @pageView.snapBottom(y)

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      width: width
      height: height

  reflow: ->
    $.ajax
      method: 'POST'
      url: "#{@composer.edition.url()}/render_text_area.html"
      data:
        composing: true
        content_item: @model.toJSON()
      success: (response) =>
        @$el.html $(response).html()
        @needsReflow = false
        @render()
