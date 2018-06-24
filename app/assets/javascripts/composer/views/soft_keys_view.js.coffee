App = Dreamtool

class App.SoftKeysView extends App.View

  className: 'soft-keys'

  initialize: ->

    @html """

    """

    @keys = {}

    @createKey('exit')
    @createKey('group')
    @createKey('ungroup')
    @createKey('delete')

  # Creates a key
  createKey: (name, text) ->
    $el = $("<button class='#{name}-key'>#{text||name}</button>")
    $el.hide()
    @append $el[0]
    @keys[name] = $el


    # btn = document.createElement('button')
    # btn.classList = key
    # @$el.append()


  showKey: (name) ->
    @keys[name].show()

  hideKey: (name) ->
    @keys[name].hide()
