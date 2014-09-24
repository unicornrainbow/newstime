class @Newstime.AddPageButton extends Backbone.View

  initialize: (options) ->
    @$el.html """
      <div class="grid grid24">
        <div class="row">
          <div class="col span24">
            <input class="add-page-btn" type="button" value="Add Page"></input>
          </div>
        </div>
      </div>
    """
