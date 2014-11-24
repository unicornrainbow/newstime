class @Newstime.CanvasItemsView extends Backbone.View

  initialize: (options) ->
    @edition = options.edition
    @$el.addClass 'canvas-items-view'

    @contentItemCollection = @edition.get('content_items')
    @canvasItems = []

    @bind 'mousemove', @mousemove

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


  mousemove: (e) ->
    # We need to have an internal copy of where things are and at what level.
    # This should allow us to map mouse moves into the correct canvas item, and
    # further be smart about how we break things down. We will control
    # positioning, which means we will need to listen to changes on each of the
    # models. We also need to know the page for each item, to be able to
    # calculate the offset.
    e = @getMappedEvent(e)

    console.log e

  setPosition: (position) ->
    @left   = position.left
    @top    = position.top
    @height = position.height
    @width  = position.width
    @$el.css position

  addCanvasItems: (canvasItems) ->
    # TODO: Need to understand the page associated with the canvas item.
    _.each canvasItems, (item) =>
      @canvasItems.push item
      @$el.append item.el

  getMappedEvent: (event) ->
    event = new Newstime.Event(event)                         # Wrap event in a newstime event object, copies coords.
    [event.x, event.y] = @mapExternalCoords(event.x, event.y) # Map coordinates
    return event                                              # Return event with mapped coords.

  mapExternalCoords: (x, y) ->
    x -= @left
    y -= @top
    return [x, y]
