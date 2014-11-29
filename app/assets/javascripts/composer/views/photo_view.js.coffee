#= require ./canvas_item_view

class @Newstime.PhotoView extends Newstime.CanvasItemView

  initialize: (options) ->
    super
    #@$el.addClass 'photo-view'

    #@setContentEl(options.contentEl) if options.contentEl

    #@bind 'paste', @paste

    #@propertiesView = new Newstime.PhotoPropertiesView(target: this)


    #@model.bind 'change:photo_id', @photoChanged, this

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

  photoChanged: ->
    if @$contentEl?
      @$contentEl.css "background-image": "url('#{@model.get('edition_relative_url_path')}')"

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
    #item = e.originalEvent.clipboardData.items[0]
    #if item && item.type.indexOf "image" != -1
      #blob   = item.getAsFile()
      #URLObj = window.URL || window.webkitURL
      #source = URLObj.createObjectURL(blob)
      #@$contentEl.css "background-image": "url('#{source}')"

    # Now we should upload and save this image to the server. When it has been
    # saved, we should update the image linkes. Perhaps we should simply upload.
    #

    item = e.originalEvent.clipboardData.items[0]
    if item && item.type.indexOf "image" != -1
      # Get image file from clipboard item.
      attachment = item.getAsFile()

      # Construct form data and upload the file.
      form = new FormData()
      file_name = Math.random().toString(36).substring(7)
      form.append("photo[attachment]", attachment, file_name)
      form.append("photo[name]", file_name)

      $.ajax
        url: '/photos'
        type: 'POST'
        data: form
        cache: false
        dataType: 'json'
        processData: false
        contentType: false
        success: (data, textStatus, jqXHR) =>
          @model.set
            photo_id: data['_id']
            edition_relative_url_path: data['edition_relative_url_path']

        #error: (jqXHR, textStatus, errorThrown) ->
          #console.log('ERRORS: ' + textStatus)
