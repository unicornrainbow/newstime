
App = Dreamtool

{min, max} = Math

# Limits return value to a min and max.
minmax = (x, y, z) ->
  min max(x, y), z

class SideMenu extends App.View

  # tagName: 'UL'
  className: 'side-menu'

  events:
    'touchstart': 'touchstart'
    'touchmove':  'touchmove'
    'touchend':   'touchend'


  template: """
    <ul class='menu'>
      <li>
          <label class='edition-settings'>Edition Settings</label>
          <ul class="edition-settings">
            <li>
              Page Width
              <ul class="page-width">
                <li><label><input type='checkbox'>240px</input></label></li>
                <li><label><input type='checkbox'>480px</input></label></li>
                <li><label><input type='checkbox'>960px</input></label></li>
                <li><label><input type='checkbox'>1080px</input></label></li>
              </ul>
            </li>
          </ul>
          <film></film>
      </li>
    </ul>
    <overlay></overlay>
  """

  initialize: (options)->
    @$html @template
    @model     = new Backbone.Model
    @menuWidth = 320#px

    # Duplicate el
    # console.log @$el[0].ownerDocument
    # @$clone = @$el.clone(true)
    # @$clone.addClass 'clone'

    # console.log @$clone[0]
    # https://stackoverflow.com/a/40954205 ty
    # @setElement [@$el, @$clone].reduce($.merge)
    # @setElement $([@$el[0], @$clone[0]]) # Doesn't work, how strange
    # @$el.hide() # right: '75px'

    @$left = @$('ul.menu')
    @$right = @$left.clone(true)

    @$el.append(@$right.get())

    @$left.addClass 'left'
    @$right.addClass 'right'

    # Memoize
    @$film      = @$('film')
    @$leftFilm  = @$('.left film')
    @$rightFilm = @$('.right film')
    @$overlay   = @$('overlay')

    # @mc = new Hammer(@el)
    # @mc.on 'tap .edition-settings', @tap

    @bindUIEvents()
    @listenTo @model, 'change:right', @render

    @render

  render: ->
    offset = @menuWidth + @model.get('right')

    @$left.css
      transform: "rotateY(#{90*(1-offset/@menuWidth)}deg)"

    @$right.css
      transform: "rotateY(-#{90*(1-offset/@menuWidth)}deg)"

    width = @$left.width()

    # console.log 'width', width

    @$el.css
      width: width*2

    @$left.css
      right: width-160+width

    @$right.css
      right: 0

    @$film.css
      opacity: 1-max(offset-(@menuWidth/2), 0)/160

    @$overlay.css
      opacity: 1-offset/@menuWidth

  trackSlide: ->
    @removeClass 'slide'
    $composer.tracking(this)

    @listenTo $composer, 'tracking-release', @close

  touchstart: ->
    # unless @model.get('open')
    @trackSlide()

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
    @model.set 'open', false
    @close()
    setTimeout (=> @removeClass 'slide'), 300

  open: ->
    @model.set 'open', true
    @addClass 'slide'
    @right = 0
    @model.set {@right}

  close: ->
    @stopListening $composer, 'tracking-release'
    $composer.trackingRelease()
    @addClass 'slide'
    @right = -@menuWidth

    @model.set {@right}
    @render()

  hit: (x, y) ->
    @windowWidth = $(window).width()

    if x > @windowWidth - 11
      return true



App.SideMenu = SideMenu
