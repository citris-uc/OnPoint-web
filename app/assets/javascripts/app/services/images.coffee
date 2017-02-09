service = ($resource) ->
  return $resource "/api/v0/ocr", null, {
    "parse": {method: "PUT", url: "/api/v0/images/parse"}
  }

angular.module('onpoint.services').factory("Image", ["$resource", service]);
