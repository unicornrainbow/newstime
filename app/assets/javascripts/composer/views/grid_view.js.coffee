@Newstime = @Newstime || {}

class @Newstime.GridView extends Backbone.View

  initialize: (options) ->
    pageWidth = 1184
    columns = 24
    gutterWidth = 16

    columnWidth = (pageWidth - (gutterWidth * (columns - 1))) / columns

    ## Compute Left Steps
    firstStep = gutterWidth/2
    columnStep = columnWidth + gutterWidth
    @leftSteps = _(columns).times (i) ->
      columnStep * i + firstStep

    firstStep = columnWidth
    columnStep = columnWidth + gutterWidth
    @rightSteps = _(columns).times (i) ->
      columnStep * i + firstStep

  snapLeft: (value) ->
    Newstime.closest(value , @leftSteps)

  snapRight: (value) ->
    Newstime.closest(value , @rightSteps)
