ctrl = ($scope, $attrs, Image, Upload) ->
  $scope.params = {}
  $scope.state = {loading: false}
  $scope.drugs = []
  $scope.images = angular.fromJson($attrs.images)
  $scope.results = {}

  $scope.upload = () ->
    $scope.state.loading = true
    $scope.result        = {}

    req = Upload.upload({
      url: '/api/v0/images/parse',
      method: "PUT",
      data: {file: $scope.file}
    })
    req.then (response) ->
      $scope.result = response.data
    req.catch (res) ->
      $scope.$emit(onpoint.error, res)
    req.finally (response) ->
      $scope.state.loading = false


  $scope.parse = (img) ->
    $scope.state.loading = true
    $scope.result        = {}

    req = Image.parse({image: img}).$promise
    req.then (response) ->
      $scope.result = response
    req.catch (res) ->
      $scope.$emit(onpoint.error, res)
    req.finally (response) ->
      $scope.state.loading = false


angular.module("onpoint.controllers").controller("imageCtrl", ["$scope", "$attrs", "Image", "Upload", ctrl]);
