#= require ../views/panel_view
#
class @Newstime.PagesPanelView extends @Newstime.PanelView

  _.extend @::events,
    'click .pages-panel-page': 'clickPagesPanelPage'
    'click .pages-panel-item': 'clickPagesPanelItem'

  initializePanel: ->
    @$el.addClass 'pages-panel'

    @viewOptions = {}

    @model.set(width: 200, height: 200)

    # Render each page
    @template = _.template """
      <ol>
      <% _.each(pages, function (page) { %>
        <li class="pages-panel-page" data-id="<%= page.cid %>"><%= page.name %></li>
        <% if (page.options.collapsed != true) { %>
          <% if (page.items.length > 0) { %>
            <ol>
              <% _.each(page.items, function (item) { %>
                <li class="pages-panel-item indent-level-1 <%= item.selected ? "selected" : "" %>"
                    data-id="<%= item.cid %>"><%= item.name %></li>
              <% }); %>
            </ol>
          <% } %>
        <% } %>
      <% }); %>
      </ol>
    """

    #setInterval _.bind(@renderPanel, this), 200
    @listenTo @composer.canvas, 'change', @renderPanel

  clickPagesPanelPage: (e) ->
    $target = $(e.target)
    viewID = $target.data('id')
    @viewOptions[viewID] ?= {}
    @viewOptions[viewID].collapsed = !@viewOptions[viewID].collapsed
    @renderPanel()

  clickPagesPanelItem: (e) =>
    $target = $(e.target)
    viewID = $target.data('id')

    # Find view by cid
    view = @composer.canvas.findViewByCID(viewID)

    if e.shiftKey
      @composer.addToSelection(view)
    else
      @composer.select(view)

  renderPanel: ->
    pages = _.map @composer.canvas.pageViewsArray, (view) =>
      page = {}
      page.name = view.uiLabel
      page.cid = view.cid
      page.options = @viewOptions[view.cid] || {}
      page.items = _.map view.contentItemViewsArray, (itemView) ->
        item = {}
        item.name = itemView.uiLabel
        item.cid = itemView.cid
        item.selected = itemView.selected
        item
      page

    @$body.html @template _.extend @model.toJSON(),
      pages: pages
