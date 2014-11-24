class @Newstime.PagesView extends Backbone.View

  initialize: (options) ->
    @edition = options.edition
    @pageCollection = @edition.get('pages')

    ## Capture and Init pages
    @pages = []

    # The direct childern of the pages view object should be the pages, this
    # enables decomposition and adding.
    @$el.children().each (i, el) =>
      id = $(el).data('page-id')
      model = @pageCollection.findWhere(_id: id)
      page = new Newstime.PageComposeView
        el: el
        page: model
        edition: @edition
        #canvasLayerView: this
        #composer: @composer
        #toolbox: @toolbox

      @pages.push page

    #_.each @pageViews, (pageView) =>
      #pageView.bind 'tracking', @tracking, this
      #pageView.bind 'focus', @handlePageFocus, this
      #pageView.bind 'tracking-release', @trackingRelease, this

  eachPage: (fn) ->
    _.each @pages, fn

  getPosition: ->
    position = @$el.offset()
    position.height = @$el.height()
    position.width = @$el.width()
    position
