#= require ./canvas_item_view

class @Newstime.PhotoView extends @Newstime.CanvasItemView

  initialize: (options) ->
    super
    @$el.addClass 'photo-view'

    @setContentEl(options.contentEl) if options.contentEl

    @bind 'paste', @paste

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

  createImage: (source) ->
   pastedImage = new Image()
   pastedImage.onload = ->
     $("body").append(this)
     console.log this.src
     #$(this).appendTo(document)
   pastedImage.src = source


  paste: (e) =>
    # Note: Code derived http://joelb.me/blog/2011/code-snippet-accessing-clipboard-images-with-javascript/
    item = e.originalEvent.clipboardData.items[0]
    if item && item.type.indexOf "image" != -1
      blob   = item.getAsFile()
      URLObj = window.URL || window.webkitURL
      source = URLObj.createObjectURL(blob)
      @$contentEl.css "background-image": "url('#{source}')"
