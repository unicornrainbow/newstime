
App = Dreamtool

{min, max} = Math

# Limits return value to a min and max.
minmax = (x, y, z) ->
  min max(x, y), z

class SideMenu extends App.View

  # tagName: 'UL'
  className: 'side-menu'

  # events:
  #   'tap': 'tap'

  template: """
    <ul class='menu'>
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


    @$film = @$('film')
    @$leftFilm = @$('.left film')
    @$rightFilm = @$('.right film')
    @$overlay = @$('overlay')

    # @mc = new Hammer(@el)
    # @mc.on 'tap', @tap

    @bindUIEvents()
    @listenTo @model, 'change', @render

    @render

  render: ->
    offset = @menuWidth + @model.get('right')
    # console.log offset/2

    # Outer
    $(@$left[0]).css
      # width: offset/2
      # right: offset/2
      # right: offset/2 - (1-offset/@menuWidth)*80
      # right: 160*offset/@menuWidth - (1-offset/@menuWidth)*80
      transform: "rotateY(#{90*(1-offset/@menuWidth)}deg)"

    # console.log offset/@menuWidth*80-80

    @$right.css
      # width: offset/2
      # right: offset/@menuWidth*80-80
      transform: "rotateY(-#{90*(1-offset/@menuWidth)}deg)"

    width = @$right.width()

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



    # @$el.css 'width', (@menuWidth + @model.get('right')) / (2-((-@model.get('right'))/320)) # *  (((-@model.get('right'))/320)+1)

    # console.log (2-((-@model.get('right'))/320))
    # $(@$el[0]).css 'right', (@model.get('right') + 160 )/ (((-@model.get('right'))/320)+1)

    # @$clone.css @model.pick('right')

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
