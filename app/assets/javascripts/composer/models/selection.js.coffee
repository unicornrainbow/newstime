@Newstime = @Newstime || {}

## The model of a selection that is drawing on a page.

# The selection has a position x,y and a height and width.
# When any of these value change, change events will occur, that allow for the
# view to listen to and update accordingly.
class @Newstime.Selection extends Backbone.RelationalModel

  initialize: (attributes, options) ->

  getGeometry: ->
    @pick('top', 'left', 'height', 'width')
