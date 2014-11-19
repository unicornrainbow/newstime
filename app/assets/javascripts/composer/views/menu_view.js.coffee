class @Newstime.MenuView extends Backbone.View

  initialize: (options) ->
    @$el.addClass "menu-view"

    @$el.html """
      <div class="container">
        <span class="menu-title">View</menu>
      </div>
    """
