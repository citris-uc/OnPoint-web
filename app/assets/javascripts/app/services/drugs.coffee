service = ($resource) ->
  return $resource "/api/v0/drugs", null, {
    "update": {method: "PUT"}
  }

angular.module('onpoint.services').factory("Drug", ["$resource", service]);
