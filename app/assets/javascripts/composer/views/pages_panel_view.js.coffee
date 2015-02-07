#= require ../views/panel_view
#
class @Newstime.PagesPanelView extends @Newstime.PanelView

  initializePanel: ->
    @model.set(width: 200, height: 200)

    # Render each page
    @template = _.template """
      <ol>
      <% _.each(pages, function (page) { %>
        <li><%= page.name %></li>
        <% if (page.items.length > 0) { %>
          <ol>
            <% _.each(page.items, function (item) { %>
              <li><%= item.name %></li>
            <% }); %>
          </ol>
        <% } %>
      <% }); %>
      </ol>
    """

    #setInterval _.bind(@renderPanel, this), 200
    @listenTo @composer.canvas, 'change', @renderPanel

  renderPanel: ->
    pages = _.map @composer.canvas.pageViewsArray, (view) ->
      page = {}
      page.name = view.model.get('number')
      page.items = _.map view.contentItemViewsArray, (itemView) ->
        item = {}
        item.name = itemView
        item
      page



    @$body.html @template _.extend @model.toJSON(),
      pages: pages
