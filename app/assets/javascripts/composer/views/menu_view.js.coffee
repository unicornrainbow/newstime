class @Newstime.MenuView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-view"

    @$el.html """
      <div class="container">
        #{JST["composer/templates/newstime_logo"]()}
        <span class="menu-title">Edition</span>
        <span class="menu-title">Section</span>
        <span class="menu-title">View</span>
      </div>
    """

    @$menuTitles = @$('.menu-title')

    @bindUIEvents()

  mousemove: (e) ->
    #console.log "Hit"
