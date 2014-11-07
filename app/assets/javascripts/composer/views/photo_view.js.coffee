#= require ./canvas_item_view

class @Newstime.PhotoView extends @Newstime.CanvasItemView

  initialize: (options) ->
    super
    @$el.addClass 'photo-view'

    @setContentEl(options.contentEl) if options.contentEl

    @propertiesView = new Newstime.PhotoPropertiesView(target: this)

    @modelChanged()

  setContentEl: (contentEl) ->
    @$contentEl = $(contentEl)

  modelChanged: ->
    super()

    if @$contentEl?
      @$contentEl.css _.pick @model.changedAttributes(), 'top', 'left', 'width', 'height'

  modelDestroyed: ->
    super()
    @$contentEl.remove() if @$contentEl?
