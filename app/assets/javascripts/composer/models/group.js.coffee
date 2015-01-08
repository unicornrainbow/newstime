class @Newstime.Group extends Backbone.RelationalModel
  idAttribute: '_id'

class @Newstime.GroupCollection extends Backbone.Collection
  model: Newstime.Group
  url: ->
    "#{@edition.url()}/pages"
