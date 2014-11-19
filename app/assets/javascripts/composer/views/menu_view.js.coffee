class @Newstime.MenuView extends Backbone.View

  initialize: (options) ->
    @$el.addClass "menu-view"

    @$el.html """
      <div class="container">
        <span class="menu-title">View</menu>
        <span class="menu-title">Section</menu>
        <span class="menu-title">Edition</menu>
      </div>
    """
