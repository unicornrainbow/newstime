app = angular.module("app")
app.directive "headlineControl", [ '$window', '$document', ( $window, $document ) ->
  {
    restrict: "A"
    #controller: 'headlineControlController'
    link: (scope, elem, attr, ctrl) ->
      elem.bind 'click', (e) ->
        alert "Show Options, expand menu"
  }
]
