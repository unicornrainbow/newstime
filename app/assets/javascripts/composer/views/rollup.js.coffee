#= require ../views/panel_view
@Dreamtool = @Dreamtool or {}

class @Dreamtool.Rollup extends Newstime.PanelView

  initialize: (options) ->
    super
    @$el.addClass('rollup')
    @model.set('bottom', 0)

  render: ->
    @$el.css @model.pick('width', 'top', 'bottom', 'left')
    @$el.css 'z-index': @model.get('z_index')
    @$el.toggle !@hidden
    @$el.toggleClass 'unhooked', @unhooked
    @renderPanel() if @renderPanel

  move: (x, y) ->
    x -= @leftMouseOffset
    y -= @topMouseOffset


    if @hooked
      @unhooked = @startTop - y > 70

    @model.set
      left: x
      top: y

  beginDrag: (e) ->
    super
    @$el.removeClass('rolledUp')
    @startTop = @model.get('top')

  endDrag: (e) ->
    super

    unless @hooked
      @hooked = true
      @model.set
        top: @model.get('top') + 33
    else
      if @startTop - @model.get('top') > 70
        @rollup()
      else
        # reset
        @model.set
          top: @startTop

  rollup: ->
    @$el.addClass('rolledUp')
    @hooked = false
    @unhooked = false
    @model.set
      top: window.innerHeight - 90
