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
    # Code derived http://joelb.me/blog/2011/code-snippet-accessing-clipboard-images-with-javascript/
    items = e.originalEvent.clipboardData.items
    item = items[0]
    if item
      type = item.type
      console.log type
      if type.indexOf "image" != -1
        # We have image
        blob = item.getAsFile()
        console.log blob

        URLObj = window.URL || window.webkitURL
        source = URLObj.createObjectURL(blob)

        # The URL can then be used as the source of an image
        @createImage(source)

    #if items
      ## Loop through all items, looking for any kind of image
      #_.each items, (item) ->
      #for (var i = 0; i < items.length; i++) {
         #if (items[i].type.indexOf("image") !== -1) {
            #// We need to represent the image as a file,
            #var blob = items[i].getAsFile();
            #// and use a URL or webkitURL (whichever is available to the browser)
            #// to create a temporary URL to the object
            #var URLObj = window.URL || window.webkitURL;
            #var source = URLObj.createObjectURL(blob);

            #// The URL can then be used as the source of an image
            #createImage(source);
    # Retreive pasted text. Not cross browser compliant. (Webkit)
    #console.log pastedText = e.originalEvent.clipboardData.getData('image')

    #@model.set('text', pastedText)

    # Now that we have the desired text, need to save this as the text with the
    # story text-content item, should that be our target. Also need to grab and
    # rerender the contents of the pasted text after it has been reflowed.

    #@reflow()
    #
    #console.log "Paste image"
