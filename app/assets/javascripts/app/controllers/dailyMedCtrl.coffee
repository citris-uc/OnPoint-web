ctrl = ($scope, $attrs, Drug) ->
  $scope.params = {}
  $scope.state = {loading: false}
  $scope.drugs = []

  $scope.search = () ->
    $scope.state.loading = true
    console.log("SUBMIT")
    req = Drug.dailyMedQuery({query: $scope.params.search}).$promise
    req.then (response) ->
      $scope.drugs = response
    , (response) ->
      console.log(response)
      $scope.$emit(onpoint.error, response)
    req.finally (response) ->
      $scope.state.loading = false
    return false;

angular.module("onpoint.controllers").controller("dailyMedCtrl", ["$scope", "$attrs", "Drug", ctrl]);
