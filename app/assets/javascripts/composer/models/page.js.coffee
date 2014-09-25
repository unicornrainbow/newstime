class @Newstime.Page extends Backbone.RelationalModel
  idAttribute: '_id'

  getHTML: ->
    # Example of get html for page
    $.ajax
      url: "#{@url()}.html"
      success: (data) ->
        console.log data


class @Newstime.PageCollection extends Backbone.Collection
  model: Newstime.Page
  url: ->
    "#{@edition.url()}/pages"
