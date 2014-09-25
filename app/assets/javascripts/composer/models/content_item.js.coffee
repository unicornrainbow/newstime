class @Newstime.ContentItem extends Backbone.RelationalModel
  idAttribute: '_id'

class @Newstime.ContentItemCollection extends Backbone.Collection
  model: Newstime.ContentItem

  url: ->
    "#{@edition.url()}/content_items"
