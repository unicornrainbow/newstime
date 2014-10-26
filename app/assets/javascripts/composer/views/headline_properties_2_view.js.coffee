@Newstime = @Newstime || {}

class @Newstime.HeadlineProperties2View extends Backbone.View

  initialize: ->

    @$el.html """
      <select class="font-family-select">
        <option value="Exo, sans-serif">Exo</option>
        <option value="EB Garamond, serif">Garamond</option>
      </select>
      <div>
        <select class="headline-alignment">
          <option value="left">Left</option>
          <option value="center">Center</option>
          <option value="right">Right</option>
          <option value="justify">Justify</option>
        </select>
      </div>
      <select class="headline-style">
        <option value="normal">Normal</option>
        <option value="italic">Italic</option>
      </select>
      <br>
      Size: <input class="nt-control current-font-size"></input>
      <br>
      Weight: <input class="nt-control current-font-weight"></input>
      <br>
      Margin:
        <input class="nt-control margin-top"></input>
        <input class="nt-control margin-bottom"></input>
      <br>
      Padding:
        <input class="nt-control padding-top"></input>
        <input class="nt-control padding-bottom"></input>
      <br>
      <a class="headline-delete">Delete</a>
    """
