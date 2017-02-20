ctrl = ($scope, $attrs, Image, Upload) ->
  $scope.params = {}
  $scope.state = {loading: false, failedToParse: false}
  $scope.drugs = []
  $scope.images = angular.fromJson($attrs.images)
  $scope.results = {}

  $scope.upload = () ->
    $scope.state.loading       = true
    $scope.state.failedToParse = false
    $scope.result              = {}

    req = Upload.upload({
      url: '/api/v0/images/parse',
      method: "PUT",
      data: {file: $scope.file}
    })
    req.then (response) ->
      console.log(response)
      $scope.result = response.data
      if (!$scope.result.raw_text)
        $scope.state.failedToParse = true
    req.catch (res) ->
      console.log("ERROR")
      console.log(res)
      $scope.$emit(onpoint.error, res)
    req.finally (response) ->
      $scope.state.loading = false


  $scope.parse = (img) ->
    $scope.state.loading = true
    $scope.state.failedToParse = false
    $scope.result        = {}

    req = Image.parse({image: img}).$promise
    req.then (response) ->
      $scope.result = response
      if (!$scope.result.raw_text)
        $scope.state.failedToParse = true

    req.catch (res) ->
      $scope.$emit(onpoint.error, res)
    req.finally (response) ->
      $scope.state.loading = false


angular.module("onpoint.controllers").controller("imageCtrl", ["$scope", "$attrs", "Image", "Upload", ctrl]);
