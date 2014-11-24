class @Newstime.CanvasItemsView extends Backbone.View

  initialize: (options) ->
    @edition = options.edition
    @$el.addClass 'canvas-items-view'

    @contentItemCollection = @edition.get('content_items')
    @canvasItems = []

    ## For each page, extract and place the content items onto the canvas view
    ## layer in association with the page.


    #_.each @pages, (page) =>

      #$("[headline-control]", page.$el).each (i, el) =>
        #id = $(el).data('content-item-id')
        #contentItem = @contentItemCollection.findWhere(_id: id)

        #selectionView = new Newstime.HeadlineView(model: contentItem, page: page, composer: @composer, headlineEl: el) # Needs to be local to the "page"
        #@selectionViews.push selectionView
        #@$el.append(el) # Move element from page to canvas layer
        #@$el.append(selectionView.el)

        ## Bind to events
        #selectionView.bind 'activate', @selectionActivated, this
        #selectionView.bind 'deactivate', @selectionDeactivated, this
        #selectionView.bind 'tracking', @resizeSelection, this
        #selectionView.bind 'tracking-release', @resizeSelectionRelease, this

      ## Initilize Text Areas Controls
      #$("[text-area-control]", page.$el).each (i, el) =>
        #id = $(el).data('content-item-id')
        #contentItem = @contentItemCollection.findWhere(_id: id)

        #selectionView = new Newstime.TextAreaView(model: contentItem, page: page, composer: @composer, contentEl: el) # Needs to be local to the "page"
        #@selectionViews.push selectionView
        #@$el.append(el) # Move element from page to canvas layer
        #@$el.append(selectionView.el)

        ## Bind to events
        #selectionView.bind 'activate', @selectionActivated, this
        #selectionView.bind 'deactivate', @selectionDeactivated, this
        #selectionView.bind 'tracking', @resizeSelection, this
        #selectionView.bind 'tracking-release', @resizeSelectionRelease, this

      ## Initilize Text Areas Controls
      #$("[photo-control]", page.$el).each (i, el) =>
        #id = $(el).data('content-item-id')
        #contentItem = @contentItemCollection.findWhere(_id: id)

        #selectionView = new Newstime.PhotoView(model: contentItem, page: page, composer: @composer, contentEl: el) # Needs to be local to the "page"
        #@selectionViews.push selectionView
        #@$el.append(el) # Move element from page to canvas layer
        #@$el.append(selectionView.el)


        ## Bind to events
        #selectionView.bind 'activate', @selectionActivated, this
        #selectionView.bind 'deactivate', @selectionDeactivated, this
        #selectionView.bind 'tracking', @resizeSelection, this
        #selectionView.bind 'tracking-release', @resizeSelectionRelease, this

      ## Initilize Text Areas Controls
      #$("[video-control]", page.$el).each (i, el) =>
        #id = $(el).data('content-item-id')
        #contentItem = @contentItemCollection.findWhere(_id: id)

        #selectionView = new Newstime.VideoView(model: contentItem, page: page, composer: @composer, contentEl: el) # Needs to be local to the "page"
        #@selectionViews.push selectionView
        #@$el.append(el) # Move element from page to canvas layer
        #@$el.append(selectionView.el)

        ## Bind to events
        #selectionView.bind 'activate', @selectionActivated, this
        #selectionView.bind 'deactivate', @selectionDeactivated, this
        #selectionView.bind 'tracking', @resizeSelection, this
        #selectionView.bind 'tracking-release', @resizeSelectionRelease, this

  setPosition: (position) ->
    @$el.css(position)
