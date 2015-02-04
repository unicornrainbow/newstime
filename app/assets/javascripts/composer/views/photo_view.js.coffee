#= require ./content_item_view

class @Newstime.PhotoView extends Newstime.ContentItemView

  initialize: (options) ->
    @$el.addClass 'photo-view'

    @composer = Newstime.composer
    @edition  = @composer.edition

    @model ?= @edition.contentItems.add({_type: 'PhotoContentItem'})

    super

    @propertiesView = new Newstime.PhotoPropertiesView(target: this, model: @model).render()


    @bind 'paste', @paste

    @listenTo @model, 'change:photo_id', @photoChanged

    @render()

  setElement: (el) ->
    super
    @$el.addClass 'photo-view'

  photoChanged: ->
    @$el.css "background-image": "url('#{@model.get('edition_relative_url_path')}')"

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
