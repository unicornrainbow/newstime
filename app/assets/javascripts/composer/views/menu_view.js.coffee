class @Newstime.MenuView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-view"

    @$el.html """
      <div class="container">
        #{JST["composer/templates/newstime_logo"]()}
        <span class="menu-title">View</menu>
        <span class="menu-title">Section</menu>
        <span class="menu-title">Edition</menu>
      </div>
    """

    @$menuTitles = @$('.menu-title')

    @bindUIEvents()

  mousemove: (e) ->
