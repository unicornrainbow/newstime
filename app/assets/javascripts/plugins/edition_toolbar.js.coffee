$ ->
  $.fn.editionToolbar = ->

    editionTab = $("#edition-tab", this)
    sectionTab = $("#section-tab", this)
    editionPanel = $("#edition-tab-panel", this)
    sectionPanel = $("#section-tab-panel", this)
    editionCancel = $(".cancel", editionPanel)
    sectionCancel = $(".cancel", sectionPanel)

    editionPanel.hide()
    sectionPanel.hide()

    editionTab.click ->
      sectionTab.removeClass "active"
      sectionPanel.hide()

      editionTab.toggleClass "active"
      editionPanel.toggle()

    sectionTab.click ->
      editionTab.removeClass "active"
      editionPanel.hide()

      sectionTab.toggleClass "active"
      sectionPanel.toggle()

    editionCancel.click (e) ->
      e.preventDefault()
      editionTab.removeClass "active"
      editionPanel.hide()

    sectionCancel.click (e) ->
      e.preventDefault()
      sectionTab.removeClass "active"
      sectionPanel.hide()
