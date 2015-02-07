#= require ../views/panel_view
#
class @Newstime.PagesPanelView extends @Newstime.PanelView

  _.extend @::events,
    'click .pages-panel-page': 'clickPagesPanelPage'

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
                <li class="indent-level-1"><%= item.name %></li>
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


  renderPanel: ->
    pages = _.map @composer.canvas.pageViewsArray, (view) =>
      page = {}
      page.name = view.uiLabel
      page.cid = view.cid
      page.options = @viewOptions[view.cid] || {}
      page.items = _.map view.contentItemViewsArray, (itemView) ->
        item = {}
        item.name = itemView.uiLabel
        item
      page

    @$body.html @template _.extend @model.toJSON(),
      pages: pages
