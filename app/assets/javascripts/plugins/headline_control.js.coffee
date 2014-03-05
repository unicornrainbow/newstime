$ ->
  $.fn.headlineControl = ->
    toolbar = $ """
      <div class="headline-tools">
        <div class="nt-adjust-size">
          <span class="control-btn reduce-size">-</span>
          <span>48pt</span>
          <span class="control-btn increase-size">+</span>
      </div>
    """

    increaseSizeBtn = $('.increase-size', toolbar)
    reduceSizeBtn = $('.reduce-size', toolbar)

    @prepend(toolbar)
    @addClass('headline-control')


    @mouseenter ->
      $(this).addClass 'show-tools'
      #console.log 'asd'

    @mouseleave ->
      $(this).removeClass 'show-tools'


    reduceSizeBtn.click ->
      console.log "Reduce"

    increaseSizeBtn.click ->
      console.log "Increase"


    # Add toolbar
    # Wire functions
