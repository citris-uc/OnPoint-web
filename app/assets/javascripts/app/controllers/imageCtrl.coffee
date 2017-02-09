ctrl = ($scope, $attrs, Image) ->
  $scope.params = {}
  $scope.state = {loading: false}
  $scope.drugs = []
  $scope.images = angular.fromJson($attrs.images)
  $scope.results = {}

  $scope.parse = (img) ->
    $scope.state.loading = true
    $scope.result        = {}

    req = Image.parse({image: img}).$promise
    req.then (response) ->
      console.log(response)
      $scope.result = response
    req.catch (res) ->
      $scope.$emit(onpoint.error, res)
    req.finally (response) ->
      $scope.state.loading = false

angular.module("onpoint.controllers").controller("imageCtrl", ["$scope", "$attrs", "Image", ctrl]);
