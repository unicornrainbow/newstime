class @Newstime.Color extends Backbone.RelationalModel
  idAttribute: '_id'

  Object.defineProperties @prototype,
    name:
      get: -> @get('name')
      set: (value) ->
        @set 'name', value

    value:
      get: -> @get('value')
      set: (value) ->
        @set 'value', value


class @Newstime.ColorCollection extends Backbone.Collection
  model: Newstime.Color
  url: ->
    "#{@edition.url}/colors"
