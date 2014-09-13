@Newstime = @Newstime || {}

class @Newstime.GridView extends Backbone.View

  initialize: (options) ->
    ## TODO: Get the offset to be on the grid steps
    columnWidth = 34
    gutterWidth = 16
    columns = 24

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
    @closest(value , @leftSteps)

  snapRight: (value) ->
    @closest(value , @rightSteps)

  snapTop: (value) ->
    @closest(value , @topSteps)

  snapBottom: (value) ->
    @closest(value , @bottomSteps)

  # Finds closest numeric value to goal out of a list.
  closest: (goal, ary) ->
    closest = null
    $.each ary, (i, val) ->
      if closest == null || Math.abs(val - goal) < Math.abs(closest - goal)
        closest = val
    closest
