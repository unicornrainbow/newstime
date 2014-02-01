//= require jquery
//= require jquery_ujs
//
//= require angular
//= require_self
//= require_tree ./templates
//= require_tree ./controllers
//= require_tree ./directives
//
//= require lib/jquery.easing


app = angular.module("app", ["templates"])

$(function() {
  var editionTab   = $("#edition-tab"),
      sectionTab   = $("#section-tab"),
      editionPanel = $("#edition-tab-panel"),
      sectionPanel = $("#section-tab-panel"),
      editionCancel= $(".cancel", editionPanel),
      sectionCancel= $(".cancel", sectionPanel);

  editionPanel.hide();
  sectionPanel.hide();

  editionTab.click(function(){
    sectionTab.removeClass('active')
    sectionPanel.hide()

    editionTab.toggleClass('active');
    editionPanel.toggle();
  });

  sectionTab.click(function(){
    editionTab.removeClass('active')
    editionPanel.hide()

    sectionTab.toggleClass('active');
    sectionPanel.toggle();
  });

  editionCancel.click(function(e) {
    e.preventDefault();

    editionTab.removeClass('active')
    editionPanel.hide()
  });

  sectionCancel.click(function(e) {
    e.preventDefault();

    sectionTab.removeClass('active')
    sectionPanel.hide()
  });

  captureAuthenticityToken = function() {
    return $("input[name=authenticity_token]").first().val();
  }

  var addSection  = $('.add-section'),
      sectionsNav = $('.sections-nav'),
      authenticityToken = captureAuthenticityToken();

  addSection.click(function(e){
    e.preventDefault();
    e.stopPropagation();

    var input = $(" <input class='section-nav-input' type='text'></input> ");
    addSection.before(input);

    addSection.hide();

    link = $("<a href=''></a>");
    span = $(" <span class='section-nav-input-span for-size'></span> ");
    span.html(link);
    addSection.before(span);
    span.addClass('for-sizing');

    input.focus();

    var cancel = function() {
      input.remove();
      span.remove();
    }

    var createSection = function(sectionName, opts) {
      var editionID   = "52d59b0f6f7263363a200000";
      var url         = "http://press.newstime.io/editions/" + editionID + "/sections";
      var sectionPath = sectionName + ".html"
      $.ajax({
        type: "POST",
        url: url,
        data: {
          authenticity_token: authenticityToken,
          section: {
            name: sectionName,
            path: sectionPath,
            edition_id: '52d59b0f6f7263363a200000'
          }
        },
        dataType: 'json'
      });
    }

    $document = $(document)
    var submit = function() {
      var sectionName = input.val();
      if (sectionName == '') {
        cancel();
      } else {
        var value = input.val();

        input.remove()

        link.html(value);
        link.attr({'href': value + ".html"});

        span.removeClass('for-sizing');

        addSection.before(" "); // Induce proper spacing.
        addSection.show();

        createSection(sectionName);
      }
    }

    var resize = function() {
      // Measure Invisible Span.
      link.text(input.val());
      input.css({'width': link.width() + 15 + 'px'});
    }

    // ESC to Cancel, Enter to submit.
    $(input).keyup(function(e){
      switch(e.keyCode) {
        case 27: // ESC
          cancel();
          break;
        case 13: // ENTER
          submit();
          break;
        default:
          resize();
      }
    });

  });

})
