@Newstime = @Newstime || {}

class @Newstime.ContentRegionControlView extends Backbone.View

  events:
    'click .content-region-settings': 'showSettings'

  initialize: (options) ->
    console.log "Content Region Control Init"

    @$el.addClass 'content-region-control-view'

    @$toolbar = $ """
      <div class="content-region-toolbar">
        <a class="content-region-settings"><i class="fa fa-gear"></i></a>
      </div>
    """
    @$toolbar.prependTo(@$el)


  showSettings: ->
    alert "Show Settings"
    #console.log "Content Region Control View Clicked"
