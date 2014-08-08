// ## Libraries
//= require lib/zepto
//= require lib/underscore
//= require lib/backbone
//= require faye
//
// ## App
//= require newstime_util
//= require_tree ./composer/plugins
//= require_tree ./composer/models
//= require_tree ./composer/views

var Newstime = Newstime || {};

Newstime.Composer = {
  init: function() {
    this.captureAuthenticityToken();

    //var composerModals = $(".composer-modal"),
        //contentRegionModal = $(".add-content-region"),
        //contentItemModal = $(".add-content-item").contentModal();

    var eventCaptureScreen = new Newstime.EventCaptureScreen();

    var headlineProperties = new Newstime.HeadlinePropertiesView();

    var globalKeyboardDispatch = new Newstime.GlobalKeyboardDispatch();

    var keyboard = new Newstime.Keyboard({ defaultFocus: globalKeyboardDispatch });
    //keyboard.pushFocus(textRegion) // example


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

    $('[page-compose]').each(function(i, el) {
      new Newstime.PageComposeView({el: el, eventCaptureScreen: eventCaptureScreen});
    });

    //$(".add-page-btn").addPageButton()
    //$(".add-content-region-btn").addContentRegionButton(contentRegionModal)
    //$(".add-content-btn").addContentButton(contentItemModal)

    //$(".composer-modal-dismiss").click(function(){
      //composerModals.addClass("hidden");
    //});

    // Create Vertical Rule
    //verticalRulerView = new Newstime.VerticalRulerView()
    //$('body').append(verticalRulerView.el);


    //log = console.log;  // example code, delete if you will.
    //console.log = function(message) {
      //log.call(console, message);
    //}
    //console.log("Tapping into console.log");
    //
    this.gridOverlay = $('.grid-overlay').hide();

    var toolboxView = new Newstime.ToolboxView();
    toolboxView.show();


    // This will change from platform to platform, but because
    // zoom persist across page referese, need to set it hard.
    // Could possible check client and do mapping that way. (Need good way to
    // detect retina)
    var devicePixelRatio = 2 //window.devicePixelRatio;
    var resize = function() {
      // Calibrate zoom
      var zoomLevel = window.devicePixelRatio/devicePixelRatio * 100;
      var inverseZoomLevel = devicePixelRatio/window.devicePixelRatio * 100;
      console.log(inverseZoomLevel);
      // Now we negate the zoom level by doing the inverse to the body.
      $('body').css({zoom: inverseZoomLevel + "%"});

      // And apply zoom level to the zoom target (page)
      $('.page').css({zoom: zoomLevel + "%"});
    }


    resize();
    $(window).resize(resize);

  },

  captureAuthenticityToken: function() {
    this.authenticityToken = $("input[name=authenticity_token]").first().val();
  },

  toggleGridOverlay: function() {
    this.gridOverlay.toggle();
  }
}

$(function() { Newstime.Composer.init(); });
