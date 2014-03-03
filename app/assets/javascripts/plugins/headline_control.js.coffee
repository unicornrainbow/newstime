$ ->
  $.fn.headlineControl = ->
    toolbar = $ """
      <div class="headline-tools">
        <ul class="nt-adjust-size">
          <li class="reduce-size">-</li>
          <li>48pt</li>
          <li class="increase-size">+</li>
      </div>
    """

    increaseSizeBtn = $('.increase-size', toolbar)
    reduceSizeBtn = $('.reduce-size', toolbar)

    this.before toolbar

    reduceSizeBtn.click ->
      console.log "Reduce"

    increaseSizeBtn.click ->
      console.log "Increase"


    # Add toolbar
    # Wire functions
