@Newstime = @Newstime || {}

class @Newstime.VerticalGridView extends Backbone.View

  initialize: (options) ->
    height = options.height

    # Calulate topsteps for vertical grid
    #step = 100

    #@topSteps = _.times height / step, (n) ->
      #n * step

    @topSteps = [10, height]

  snapTop: (value) ->
    closest = Newstime.closest(value, @topSteps)

    # Return closest value if within 5 pixels, otherwise value
    if Math.abs(closest - value) < 10 then closest else value
