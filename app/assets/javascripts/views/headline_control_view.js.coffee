@Newstime = @Newstime || {}

class @Newstime.HeadlineControlView extends Backbone.View

  events:
   'click .reduce-size': 'reduceSize'
   'click .increase-size': 'increaseSize'
   'mouseenter': 'showTools'
   'mouseleave': 'hideTools'

  reduceSize: ->
    fontSize = @$headline.css('font-size')
    fontSize = "#{parseInt(fontSize)-2}px"
    @$headline.css('font-size', fontSize)
    @$fontSizeStatus.text(fontSize)

  increaseSize: ->
    fontSize = @$headline.css('font-size')
    fontSize = "#{parseInt(fontSize)+2}px"
    @$headline.css('font-size', fontSize)
    @$fontSizeStatus.text(fontSize)

  showTools: ->
    @$el.addClass 'show-tools'

  hideTools: ->
    @$el.removeClass 'show-tools'


  initialize: ->
    @$el.addClass('headline-control')

    toolbar = $ """
      <div class="headline-tools">
        <div class="nt-adjust-size">
          <span class="control-btn reduce-size">-</span>
          <span class="font-size-status">48pt</span>
          <span class="control-btn increase-size">+</span>
      </div>
    """
    console.log(@$el)
    toolbar.prependTo(@$el)

    @$headline = @$el.find('h1')
    @$fontSizeStatus = @$el.find('.font-size-status')

    #increaseSizeBtn = $('.increase-size', toolbar)
    #reduceSizeBtn = $('.reduce-size', toolbar)

    #console.log $('.reduce-size', this)

    #@mouseenter ->
      #$(this).addClass 'show-tools'
      ##console.log 'asd'

    #@mouseleave ->
      #$(this).removeClass 'show-tools'


    #reduceSizeBtn.click ->
      #console.log "Reduce"

    #increaseSizeBtn.click ->
      #console.log "Increase"

    # Add toolbar
    # Wire functions
