@Newstime = @Newstime || {}

class @Newstime.TextAreaPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .story-content-item-columns': 'changeColumns'
    'change .by-line-input': 'changeByLine'
    'change .show-by-line': 'changeShowByLine'
    'change .story-title-input': 'changeStoryTitle'

  initialize: (options) ->
    @$el.addClass 'text-area-properties'
    @textAreaView = options.target # Text area view

    @$el.html """
      <li class="property">
        <label>Columns</label>
        <span class="field">
          <select class="story-content-item-columns">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
          </select>
        </span>
      </li>

      <li class="property">
        <label>By Line</label>
        <span class="field">
          <input class='show-by-line' type="checkbox"></input>
        </span>
      </li>

      <li class="property">
        <label>By</label>
        <span class="field"><input class="by-line-input" style="width: 100px;"></input></span>
      </li>

      <li class="property">
        <label>Story Title</label>
        <span class="field"><input class="story-title-input" style="width: 100px;"></input></span>
      </li>

      <li class="property">
        <label>Height</label>
        <span class="field"><input class="height-input"></input></spa>
      </li>

      <li class="property">
        <label>Width</label>
        <span class="field"><input class="width-input"></input></spa>
      </li>
    """

    @$columns = @$('.story-content-item-columns')
    @$heightInput = @$('.height-input')
    @$widthInput = @$('.width-input')
    @$showByLine = @$('.show-by-line')
    @$byLineInput = @$('.by-line-input')
    @$storyTitleInput = @$('.story-title-input')

    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove

    @render()

  render: ->
    @$columns.val(@model.get('columns'))
    @$heightInput.val(@model.get('height') + 'px')
    @$widthInput.val(@model.get('width') + 'px')
    @$showByLine.prop('checked', @model.get('show_by_line'))
    @$byLineInput.val(@model.get('by_line') || '')
    @$storyTitleInput.val(@model.get('story_title') || '')

  changeColumns: ->
    @model.set 'columns', @$columns.val()
    @textAreaView.reflow()

  changeByLine: ->
    @model.set 'by_line', @$byLineInput.val()
    @textAreaView.reflow()

  changeShowByLine: ->
    @model.set 'show_by_line', @$showByLine.prop('checked')
    @textAreaView.reflow()

  changeStoryTitle: ->
    @model.set 'story_title', @$storyTitleInput.val()
    @textAreaView.reflow()
