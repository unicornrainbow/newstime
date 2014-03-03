//= require lib/zepto
//
// ## Plugins
//= require plugins/edition_toolbar
//= require plugins/headline_control
//= require plugins/section_nav
//= require plugins/content_modal
//= require plugins/add_page_button
//= require plugins/add_content_region_button
//= require plugins/add_content_button

var Newstime = {};

Newstime.Composer = {
  init: function() {
    this.captureAuthenticityToken();

    var composerModals = $(".composer-modal"),
        contentRegionModal = $(".add-content-region"),
        contentItemModal = $(".add-content-item").contentModal();

    // Initialize Plugins
    $('#edition-toolbar').editionToolbar();
    $('#section-nav').sectionNav();
    $('[headline-control]').headlineControl();

    $(".add-page-btn").addPageButton()
    $(".add-content-region-btn").addContentRegionButton(contentRegionModal)
    $(".add-content-btn").addContentButton(contentItemModal)

    $(".composer-modal-dismiss").click(function(){
      composerModals.addClass("hidden");
    });
  },

  captureAuthenticityToken: function() {
    this.authenticityToken = $("input[name=authenticity_token]").first().val();
  },

  postForm: function(action, method, input) {
    var form;
    form = $('<form />', {
        action: action,
        method: method,
        style: 'display: none;'
    });
    if (typeof input !== 'undefined') {
      $.each(input, function (name, value) {
        $('<input />', {
          type: 'hidden',
          name: name,
          value: value
        }).appendTo(form);
      });
    }
    form.appendTo('body').submit();
  }
}

$(function() { Newstime.Composer.init(); });
