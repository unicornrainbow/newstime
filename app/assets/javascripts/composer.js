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

  var addSection  = $('.add-section'),
      sectionsNav = $('.sections-nav');

  addSection.click(function(e){
    e.preventDefault();
    e.stopPropagation();

    var input = $(" <input type='text'></input> ");
    addSection.before(input);
    input.focus();

    var cancel = function() {
      input.remove()
    }

    var createSection = function(sectionName) {
      console.log(sectionName);
      $.ajax({


      });
    }

    var submit = function() {
      var sectionName = input.val();
      if (sectionName == '') {
        cancel();
      } else {
        addSection.before(" <span><a href=''>" + sectionName + "</a></span> ");
        input.remove();
      }
    }

    // ESC to Cancel, Enter to submit.
    $(input).keyup(function(e){
      switch(e.keyCode) {
        case 27: // ESC
          cancel();
          break;
        case 13: // ENTER
          submit();
      }
    });

    // Click should submit.
    $(document).click(function(){ submit() });
  });

})
