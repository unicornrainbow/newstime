class @Newstime.ContentItem extends Backbone.RelationalModel
  idAttribute: '_id'

  initialize: (attributes) ->
    #@set('cursorPosition', (@get('text') || ' ').length, silent: true)

    @on 'change:page_id', @clearPage


  Object.defineProperties @prototype,
    top:
      get: -> @get('top')
      set: (value) ->
        @set 'top', value

    left:
      get: -> @get('left')
      set: (value) ->
        @set 'left', value

    #page:
      #get: ->
        #@getPage()
      #set: (value) ->
        #@_page = value
        #@set 'page_id', value.id

  # Gets page
  getPage: ->
    @_page ?= @get('edition').get('pages').findWhere(_id: @get('page_id'))

  setPage: (page) ->
    @_page = page
    @set 'page_id', page.get('_id')

  getGroup: ->
    @group ?= @get('edition').get('groups').findWhere(_id: @get('group_id'))


  clearPage: ->
    @page = null

  getSection: ->
    @getPage().getSection()

  # Specific to the HeadlineContentItem
  typeCharacter: (char) ->

    if @get('text')
      @set('text', @get('text') + char, silent: true)
      #@set('cursorPosition', @get('cursorPosition') + 1, silent: true)
      @trigger('change change:text')
    else
      @set('text', char, silent: true)
      #@set('cursorPosition', 1, silent: true)
      @trigger('change change:text')


    #if @get('text')
      #@set('text', @get('text').slice(0, @get('cursorPosition'))  + char + @get('text').slice(@get('cursorPosition'), @get('text').length), silent: true)
      #@set('cursorPosition', @get('cursorPosition') + 1, silent: true)
      #@trigger('change')
    #else
      #@set('text', char, silent: true)
      #@trigger('change')

  # Specific to headline content item
  backspace: ->
    @set('text', @get('text').slice(0,-1), silent: true)
    #@set('cursorPosition', Math.max(0, @get('cursorPosition') - 1), silent: true)
    @trigger('change change:text')


  # HACK: Specific to TextAreaContentItems..
  reflow: ->

    # TODO: Always start with first in the chain...
    # TODO: Acknowledge groups

    # Decide if we are part of a continuation.
    storyTitle = @get('story_title') # (Serves as the anchor reference on the page, simply need section and page reference)

    if storyTitle?

      # Get all content items with matching story title
      edition = @get('edition')
      contentItems = edition.get('content_items')
      storyContentItems = contentItems.where('story_title': storyTitle)

      # Sort content items based on section, page, y, x
      storyContentItems = storyContentItems.sort (a, b) ->
        if a.getSection().get('sequence') != b.getSection().get('sequence')
          a.getSection().get('sequence') - b.getSection().get('sequence')
        else if a.getPage().get('number') != b.getPage().get('number')
          a.getPage().get('number') - b.getPage().get('number')
        else if a.get('top') != b.get('top')
          a.get('top') - b.get('top')
        else
          a.get('left') - b.get('left')

      index = _.indexOf storyContentItems, this

      if index > 0
        previousContentItem = storyContentItems[index-1]
        leading_page = previousContentItem.getPage()
        leading_section = previousContentItem.getSection()
        @set
          lead_text_area_id: previousContentItem.get('_id')
          precedent_text: "<strong>#{@get('story_title')}</strong>, from Page #{leading_page.get('page_ref')}"
          #precedent_path: "#{leading_section.get('path')}#page-#{leading_page.get('number')}"
          #precedent_path: "#{leading_section.get('path')}##{leading_section.get('letter')}#{leading_page.get('number')}/#{storyTitle}"
          precedent_path: "#{leading_section.get('path')}##{leading_page.get('page_ref')}/#{storyTitle}"

      else
        @set
          lead_text_area_id: null
          precedent_text: null
          precedent_path: null


      if index+1 < storyContentItems.length
        nextContentItem = storyContentItems[index+1]
        trailing_page = nextContentItem.getPage()
        trailing_section = nextContentItem.getSection()

        @set
          follow_text_area_id: nextContentItem.get('_id')
          continuation_text: "See <strong>#{@get('story_title')}</strong> on Page #{trailing_page.get('page_ref')}"
          #continuation_path: "#{trailing_section.get('path')}#page-#{trailing_page.get('number')}"
          #continuation_path: "#{trailing_section.get('path')}##{trailing_section.get('letter')}#{trailing_page.get('number')}/#{storyTitle}"
          continuation_path: "#{trailing_section.get('path')}##{trailing_page.get('page_ref')}/#{storyTitle}"

      else
        @set
          follow_text_area_id: null
          continuation_text: null
          continuation_path: null


      if previousContentItem
        @set 'overflow_input_text', previousContentItem.get('overrun_html')

    $.ajax
      method: 'POST'
      url: "#{@get('edition').url()}/render_text_area.json"
      contentType: 'application/json'
      dataType: 'json'
      data:
        JSON.stringify
          composing: true
          content_item: @toJSON()
      success: (response) =>
        @set _.pick(response, 'rendered_html', 'overrun_html')

        # Trigger reflow of next content item
        nextContentItem.reflow() if nextContentItem

  initialTextArea: ->
    # Decide if we are part of a continuation.
    storyTitle = @get('story_title')

    # Get all content items with matching story title
    edition = @get('edition')
    contentItems = edition.get('content_items')
    storyContentItems = contentItems.where('story_title': storyTitle)

    # Sort content items based on section, page, y, x
    storyContentItems = storyContentItems.sort (a, b) ->
      if a.getSection().get('sequence') != b.getSection().get('sequence')
        a.getSection().get('sequence') - b.getSection().get('sequence')
      else if a.getPage().get('number') != b.getPage().get('number')
        a.getPage().get('number') - b.getPage().get('number')
      else if a.get('top') != b.get('top')
        a.get('top') - b.get('top')
      else
        a.get('left') - b.get('left')

    storyContentItems[0]

  getBoundry: ->
    new Newstime.Boundry(_.pick @attributes, 'top', 'left', 'width', 'height')

  hit: ->
    boundry = @getBoundry()
    boundry.hit.apply(boundry, arguments)


class @Newstime.ContentItemCollection extends Backbone.Collection
  model: Newstime.ContentItem

  url: ->
    "#{@edition.url()}/content_items"
