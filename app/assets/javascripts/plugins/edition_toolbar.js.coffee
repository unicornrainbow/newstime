$ ->
  $.fn.editionToolbar = ->

    editionTab = $("#edition-tab", this)
    sectionTab = $("#section-tab", this)
    printsTab = $("#prints-tab", this)

    editionPanel = $("#edition-tab-panel", this)
    sectionPanel = $("#section-tab-panel", this)
    printsPanel = $("#prints-tab-panel", this)

    editionCancel = $(".cancel", editionPanel)
    sectionCancel = $(".cancel", sectionPanel)

    editionPanel.hide()
    sectionPanel.hide()
    printsPanel.hide()

    editionTab.click ->
      sectionTab.removeClass "active"
      sectionPanel.hide()
      printsTab.removeClass "active"
      printsPanel.hide()

      editionTab.toggleClass "active"
      editionPanel.toggle()

    sectionTab.click ->
      editionTab.removeClass "active"
      editionPanel.hide()
      printsTab.removeClass "active"
      printsPanel.hide()

      sectionTab.toggleClass "active"
      sectionPanel.toggle()

    printsTab.click ->
      editionTab.removeClass "active"
      editionPanel.hide()
      sectionTab.removeClass "active"
      sectionPanel.hide()

      printsTab.toggleClass "active"
      printsPanel.toggle()

    editionCancel.click (e) ->
      e.preventDefault()
      editionTab.removeClass "active"
      editionPanel.hide()

    sectionCancel.click (e) ->
      e.preventDefault()
      sectionTab.removeClass "active"
      sectionPanel.hide()
