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

//$(function() {
  //$(".add-page-btn").click(function() {
    //alert("Add Page")
  //});
//});

app = angular.module("app", ["templates"])

//angular.element(document).ready(function() {
  //angular.bootstrap(document, ['app']);
//});
//
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
    // Find a authenticity token
    //captureAuthenticityToken();
    //""
  }

  var addSection  = $('.add-section'),
      sectionsNav = $('.sections-nav'),
      authenticityToken = captureAuthenticityToken();

  addSection.click(function(e){
    e.preventDefault();
    e.stopPropagation();

    var input = $(" <input class='section-nav-input' type='text'></input> ");
    addSection.before(input);
    input.focus();

    // Submits if document is clicked anywhere.
    var clickHandler = function(){ submit() }

    var cancel = function() {
      clickHandler
      input.remove()
    }

    var createSection = function(sectionName, opts) {
      var editionID = "52d59b0f6f7263363a200000";
      var url = "http://press.newstime.io/editions/" + editionID + "/sections";

      $.ajax({
        type: "POST",
        url: url,
        data: {
          authenticityToken: authenticityToken,
          name: sectionName
        },
        success: opts['success'],
        error: opts['error'],
        dataType: 'json'
      });
    }


    $document = $(document)
    var submit = function() {
      var sectionName = input.val();
      if (sectionName == '') {
        cancel();
      } else {
        $document.unbind(clickHandler); // Remove click handler which was bound.
        var success = function() {
          alert("success");
        };

        var error = function() {
          alert("error");
        };

        addSection.before(" <span><a href=''>" + sectionName + "</a></span> ");
        createSection(sectionName, {
          success: success,
          error: error
        });

        input.remove();
      }
    }

    // Click should submit.
    $document.click(clickHandler);

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
          // Resize form field.
      }
    });

  });

})
