service = ($resource) ->
  return $resource "/api/v0/drugs", null, {
    "update": {method: "PUT"},
    "dailyMedQuery": {method: "GET", url: "/api/v0/drugs/dailymed"}
  }

angular.module('onpoint.services').factory("Drug", ["$resource", service]);
