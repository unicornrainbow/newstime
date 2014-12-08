#= require ./canvas_item_view

class @Newstime.TextAreaView extends Newstime.CanvasItemView

  initialize: (options) ->
    super

    #@$el.addClass 'text-area-view'

    #@lineHeight = parseInt(Newstime.config.storyTextLineHeight)

    #@bind 'paste', @paste
    #@bind 'dblclick',  @dblclick

    #@bind 'resized', @reflow, this  # Reflow text on resize

    #@setContentEl(options.contentEl) if options.contentEl

    @propertiesView = new Newstime.TextAreaPropertiesView(target: this)

    #@modelChanged()

  setContentEl: (contentEl) ->
    @$contentEl = $(contentEl)

  modelChanged: ->
    super()

    if @$contentEl?
      @$contentEl.css
        top: @model.get('top') + @pageTop
        left: @model.get('left') + @pageLeft
      @$contentEl.css _.pick @model.changedAttributes(), 'width', 'height'

  modelDestroyed: ->
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
    height = @page.snapBottom(y) - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      height: height

  dragBottomLeft: (x, y) ->
    geometry = @getGeometry()
    x = @page.snapLeft(x)
    y = @page.snapBottom(y)

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: height

  dragBottomRight: (x, y) ->
    geometry = @getGeometry()
    width = @page.snapRight(x - geometry.left)
    y = @page.snapBottom(y)

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
        if @$contentEl
          @$contentEl.html $(response).html()
          @$contentEl.show()
