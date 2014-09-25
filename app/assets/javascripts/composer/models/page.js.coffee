class @Newstime.Page extends Backbone.RelationalModel
  idAttribute: '_id'

class @Newstime.PageCollection extends Backbone.Collection
  model: Newstime.Page
  url: ->
    "#{@edition.url()}/pages"
