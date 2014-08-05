//= require lib/zepto
//= require lib/underscore
//= require lib/backbone
//= require faye
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
//= require views/palette_view
//
//= require views/headline_control_view
//= require views/headline_properties_view
//
//= require views/story_text_control_view
//= require views/story_properties_view
//
//= require views/content_region_control_view
//= require views/content_region_properties_view
//
//= require views/photo_control_view
//= require views/photo_properties_view
//
//= require views/properties_panel_view

var Newstime = Newstime || {};

Newstime.Composer = {
  init: function() {
    this.captureAuthenticityToken();

    var composerModals = $(".composer-modal"),
        contentRegionModal = $(".add-content-region"),
        contentItemModal = $(".add-content-item").contentModal();

    var headlineProperties = new Newstime.HeadlinePropertiesView();

    // Initialize Plugins
    $('#edition-toolbar').editionToolbar();
    $('#section-nav').sectionNav();
    $('[headline-control]').headlineControl(headlineProperties);

    var storyPropertiesView = new Newstime.StoryPropertiesView();
    $('[story-text-control]').each(function(i, el) {
      new Newstime.StoryTextControlView({el: el, toolPalette: storyPropertiesView});
    });

    var contentRegionPropertiesView = new Newstime.ContentRegionPropertiesView();
    $('[content-region-control]').each(function(i, el) {
      new Newstime.ContentRegionControlView({el: el, propertiesView: contentRegionPropertiesView});
    });

    var photoPropertiesView = new Newstime.PhotoPropertiesView();
    $('[photo-control]').each(function(i, el) {
      new Newstime.PhotoControlView({el: el, propertiesView: photoPropertiesView});
    });

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
