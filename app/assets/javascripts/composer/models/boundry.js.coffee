
# An object which represents a boundry which can be used for hit and collision
# detection.
#
# Example
#
#   boundry = new Newstime.Boundry
#     top: 10
#     left: 10
#     width: 100
#     height: 100
#
#   boundry.left      # => 10
#   boundry.right     # => 110
#
class @Newstime.Boundry

  constructor: (properties) ->
    _.extend(this, properties)

  Object.defineProperties @prototype,
    # Top boundry as measured from top.
    top:
      get: -> @_top
      set: (value) ->
        @_top = value
        @_bottom = @top + @height

    # Left boundry as measure from left side of container.
    left:
      get: -> @_left
      set: (value) ->
        @_left = value
        @_right = @left + @width

    # Distance between left and right boundries.
    width:
      get: -> @_width
      set: (value) ->
        @_width = value
        @_right = @left + @width

    # Distance between top and bottom boundries.
    height:
      get: -> @_height
      set: (value) ->
        @_height = value
        @_bottom = @top + @height

    # Bottom boundry as measure from top.
    bottom:
      get: -> @_bottom
      set: (value) ->
        @_bottom = value
        @_height = @bottom - @top

    # Right boundry, as measured from left.
    right:
      get: -> @_right
      set: (value) ->
        @_right = value
        @_width = @right - @left

  # Returns a unionized boundry with this boundry.
  union: (boundry) ->
    union = new Newstime.Boundry()
    union.top = Math.min(@top, boundry.top)
    union.left = Math.min(@left, boundry.left)
    union.bottom = Math.max(@bottom, boundry.bottom)
    union.right = Math.max(@right, boundry.right)
    return union
