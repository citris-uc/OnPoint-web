(function () {
  angular.module('onpoint.directives', ["ui-notification"]);
  angular.module('onpoint.controllers', []);
  angular.module('onpoint.services', ["ngResource"]);

  angular.module('onpoint', [
    'onpoint.directives',
    'onpoint.controllers',
    'onpoint.services',
    'ui-notification',
    'ngFileUpload'
  ]).run(["$rootScope", "Notification", function($rootScope, Notification) {

    $rootScope.$on(onpoint.success, function(event, response) {
      Notification.success({message: "Success!", positionY: 'top', positionX: 'right'});
      if (response.reload)
        window.location.reload()
      if (response.redirect_path)
        window.location.href = response.redirect_path
    })

    $rootScope.$on(onpoint.error, function(event, response) {
      if (response.status == 0 || response.status == 500)
        message = "Something went wrong on our end. Please try again!"
      else if (response.responseJSON)
        message = response.responseJSON.error
      else
        message = response.data.error
      Notification.error({message: message, positionY: 'top', positionX: 'right'});
    })


  }])
}());

$(document).on('ready page:load', function()
{
  angular.bootstrap(document.body, ['onpoint'])
});
