app = angular.module("app")
app.directive "editionToolbar", [ '$window', '$document', ( $window, $document ) ->
  {
    restrict: "A"
    controller: 'editionToolbarController'
    link: (scope, elem, attr, ctrl) ->
      elem.bind 'click', (e) ->
        alert "Show Options, expand menu"
        #scope.sectionMenu.menuVisible = !scope.sectionMenu.menuVisible
        #elem.toggleClass('menu-open')
        #scope.$apply()

  }
]
