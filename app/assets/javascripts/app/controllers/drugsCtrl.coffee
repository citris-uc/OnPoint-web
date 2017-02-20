ctrl = ($scope, $attrs, Drug) ->
  $scope.params = {}
  $scope.state = {loading: false}
  $scope.drugs = []

  $scope.search = () ->
    $scope.drugs = []
    $scope.state.loading = true

    req = Drug.query({query: $scope.params.search}).$promise
    req.then (response) ->
      console.log(response)
      $scope.drugs = response
    req.catch (response) -> $scope.$emit(onpoint.error, response)
    req.finally (response) ->
      $scope.state.loading = false
    return false;

angular.module("onpoint.controllers").controller("drugsCtrl", ["$scope", "$attrs", "Drug", ctrl]);
