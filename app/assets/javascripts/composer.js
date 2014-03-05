//= require lib/zepto
//= require lib/underscore
//= require lib/backbone
//
// ## Plugins
//= require newstime_util
//= require plugins/edition_toolbar
//= require plugins/headline_control
//= require plugins/section_nav
//= require plugins/content_modal
//= require plugins/add_page_button
//= require plugins/add_content_region_button
//= require plugins/add_content_button
//
//= require views/headline_control_view
//= require views/headline_toolbar_view

var Newstime = Newstime || {};

Newstime.Composer = {
  init: function() {
    this.captureAuthenticityToken();

    var composerModals = $(".composer-modal"),
        contentRegionModal = $(".add-content-region"),
        contentItemModal = $(".add-content-item").contentModal();


    headlineToolbar = new Newstime.HeadlineToolbarView();
    $('body').append(headlineToolbar.el);

    // Initialize Plugins
    $('#edition-toolbar').editionToolbar();
    $('#section-nav').sectionNav();
    $('[headline-control]').headlineControl(headlineToolbar);

    $(".add-page-btn").addPageButton()
    $(".add-content-region-btn").addContentRegionButton(contentRegionModal)
    $(".add-content-btn").addContentButton(contentItemModal)

    $(".composer-modal-dismiss").click(function(){
      composerModals.addClass("hidden");
    });
  },

  captureAuthenticityToken: function() {
    this.authenticityToken = $("input[name=authenticity_token]").first().val();
  }
}


$(function() { Newstime.Composer.init(); });
