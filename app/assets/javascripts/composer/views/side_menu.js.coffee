
App = Dreamtool

{min, max} = Math

# Limits return value to a min and max.
minmax = (x, y, z) ->
  min max(x, y), z

class SideMenu extends App.View

  tagName: 'UL'
  className: 'side-menu'

  # events:
  #   'tap': 'tap'

  template: """
    <li>
      Edition Settings
      <ul class="edition-settings">
        <li>
          Page Width
          <ul class="page-width">
            <li><input type='checkbox'>240px</input></li>
            <li><input type='checkbox'>480px</input></li>
            <li><input type='checkbox'>960px</input></li>
            <li><input type='checkbox'>1080px</input></li>
          </ul>
        </li>
      </ul>
    </li>

  """

  initialize: (options)->
    @$html @template
    @model = new Backbone.Model
    @menuWidth = 320#px

    # @mc = new Hammer(@el)
    # @mc.on 'tap', @tap

    @bindUIEvents()
    @listenTo @model, 'change', @render

    @render

  render: ->
    @$el.css @model.pick('right')

  trackSlide: ->
    @removeClass 'slide'
    $composer.tracking(this)
    @listenTo $composer, 'tracking-release', @close
    # @trigger 'tracking', this

  touchmove: (e) ->
    ww = $composer.windowWidth
    x = e.touches[0].clientX
    right = ww - x - @menuWidth # From right

    @right = minmax right, -@menuWidth, 0
    # console.log {@right}
    @model.set {@right}

  touchend: (e)->
    if @menuWidth+@right > @menuWidth/2.2
      @open()
    else
      @close()

    setTimeout (=> @removeClass 'slide'), 300

  tap: =>
    @close()
    setTimeout (=> @removeClass 'slide'), 300

  open: ->
    @addClass 'slide'
    @right = 0
    @model.set {@right}

  close: ->
    @stopListening $composer, 'tracking-release'
    $composer.trackingRelease()
    @addClass 'slide'
    @right = -@menuWidth
    @model.set {@right}



App.SideMenu = SideMenu
