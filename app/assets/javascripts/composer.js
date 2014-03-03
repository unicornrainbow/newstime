//= require lib/zepto
//
// ## Plugins
//= require plugins/edition_toolbar
//= require plugins/headline_control
//= require plugins/section_nav
//= require plugins/content_modal
//= require plugins/add_page_button

var Newstime = {};

Newstime.Composer = {
  init: function() {
    this.captureAuthenticityToken();

    var composerModals = $(".composer-modal"),
        contentRegionModal = $(".add-content-region")

    var contentModal = $(".add-content-item").contentModal();

    // Initialize Plugins
    $('#edition-toolbar').editionToolbar();
    $('#section-nav').sectionNav();
    $('[headline-control]').headlineControl();

    $(".add-page-btn").addPageButton()
    //$(".add-content-region-btn").addContentRegionButton()
    //$(".add-content-btn").addContentButton()

    $(".add-content-region-btn").click(function() {
      var pageID = $(this).data("page-id");
      var rowSequence = $(this).data("row-sequence");

      // Set hidden form field values
      $("[name='content_region[page_id]']", contentRegionModal).val(pageID);
      $("[name='content_region[row_sequence]']", contentRegionModal).val(rowSequence);

      contentRegionModal.removeClass("hidden");
    });

    $(".add-content-btn").click(function() {
      $(".content-region-id", contentItemModal).val($(this).data("content-region-id"))
      contentItemModal.removeClass("hidden")
    });

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
