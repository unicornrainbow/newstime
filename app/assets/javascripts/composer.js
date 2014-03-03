//= require lib/zepto
//
// ## Plugins
//= require plugins/edition_toolbar
//= require plugins/headline_control
//= require plugins/section_nav

var Newstime = {};

Newstime.Composer = {
  init: function() {
    this.captureAuthenticityToken();

    // Initialize Plugins
    $('#edition-toolbar').editionToolbar();
    $('#section-nav').sectionNav();
    $('[headline-control]').headlineControl();
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

$(function() {

  var createPage = function(sectionID, opts) {
    // TODO: Do we need to be passing in the sectionID in two places?
    postForm("/sections/" + sectionID + "/pages", "post", { authenticity_token: authenticityToken });
  }

  $(".add-page-btn").click(function() {
    createPage(composer.sectionID); // Temp solution, should be pulling this from the dom and using a directive.
  });

  var composerModals = $(".composer-modal");
  var contentRegionModal = $(".add-content-region");
  var contentItemModal = $(".add-content-item");
  var contentItemModalForm = $("form", contentItemModal);

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

  // HACK: This entire file needs to be designed and rewritten when the
  // prototype is done. I'm doing it this was to save time upfront.
  var handelContentItemTypeChange = function() {
    var contentRegionID = $(".content-region-id", contentItemModal).val(); // Capture content region id until we get to crazy.
    var type = $(this).val();
    $.ajax({
      type: "GET",
      url: "/content_items/form",
      data: { type: type },
      dataType: 'html',
      success: function(html){
        contentItemModalForm = $(html).replaceAll(contentItemModalForm) // Replace form

        // Rewire and reset content-region-id
        $(".content-region-id", contentItemModal).val(contentRegionID);
        $(".type-selector", contentItemModalForm).change(handelContentItemTypeChange);
      }
    });
  }

  // Wire up the content item type field loader.
  $(".type-selector", contentItemModalForm).change(handelContentItemTypeChange);

})
