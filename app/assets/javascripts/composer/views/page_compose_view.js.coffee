@Newstime = @Newstime || {}

# TODO: Goal, draw box
class @Newstime.PageComposeView extends Backbone.View

  initialize: (options) ->

    @$el.html """
      <div class="resizable"></div>
    """
