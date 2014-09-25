class @Newstime.Page extends Backbone.RelationalModel
  idAttribute: '_id'

  getHTML: (success) ->
    # Example of get html for page
    $.ajax
      url: "#{@url()}.html"
      data:
        composing: true
      success: success
      #success: (data) ->
        #console.log data


class @Newstime.PageCollection extends Backbone.Collection
  model: Newstime.Page
  url: ->
    "#{@edition.url()}/pages"
