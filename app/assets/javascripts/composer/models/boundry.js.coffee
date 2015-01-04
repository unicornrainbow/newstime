
class @Newstime.Boundry

  constructor: (top, left, width, height) ->
    @top = top
    @left = left
    @width = width
    @height = height


  Object.defineProperties @prototype,
    top:
      get: -> @_top
      set: (value) ->
        @_top = value
        @_bottom = @top + @height

    left:
      get: -> @_left
      set: (value) ->
        @_left = value
        @_right = @left + @width

    width:
      get: -> @_width
      set: (value) ->
        @_width = value
        @_right = @left + @width

    height:
      get: -> @_height
      set: (value) ->
        @_height = value
        @_bottom = @top + @height

    bottom:
      get: -> @_bottom
      set: (value) ->
        @_bottom = value
        @_height = @top - @bottom

    right: (right) ->
      get: -> @_right
      set: (value) ->
        @_right = value
        @_width = @left - @right
