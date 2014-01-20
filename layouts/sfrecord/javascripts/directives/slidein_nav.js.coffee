app = angular.module("app")

app.directive "slideinNav", [ '$window', '$document', ( $window, $document ) ->
  {
    restrict: "A"
    controller: 'slideinNavController'
    templateUrl: 'slidein_nav.html'
    scope:
      src: "@"

    link: ($scope, $element, $attrs) ->
      $window = $(window)
      showingSlideinNav = false

      angular.element($window).bind 'scroll', ->
        scrollTop    = $window.scrollTop()
        windowHeight = $window.height()

        if scrollTop < 800
          if showingSlideinNav
            # Hide nav
            showingSlideinNav = false
            $element.animate { top: -$element.height() }, 200, 'easeInOutSine', ->
              $element.hide()

        else if scrollTop >= 800
          unless showingSlideinNav
            # Show nav
            showingSlideinNav = true
            $element.css top: -$element.height()
            $element.show()
            $element.animate { top: 0 }, 200, 'easeInOutSine'


  }
]
