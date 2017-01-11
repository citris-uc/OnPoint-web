(function () {
  angular.module('clovi.directives', ["ui-notification"]);
  angular.module('clovi.controllers', []);
  angular.module('clovi.services', []);

  angular.module('onpoint', [
    'clovi.directives',
    'clovi.controllers',
    'clovi.services',
    'ui-notification'
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
        message = "Something went wrong on our end. Please try again or send an email to support@clovi.net!"
      else if (response.responseJSON)
        message = response.responseJSON.error
      else
        message = response.data.error
      Notification.error({message: message, positionY: 'top', positionX: 'right'});
    })


  }])
}());

// We turn automatic bootstrapping via %html{"ng-app" => "cloviApp"}
// so we can have AngularJS play nicely with Turbolinks.
// See: http://stackoverflow.com/questions/14797935/using-angularjs-with-turbolinks
$(document).on('ready page:load', function()
{
  angular.bootstrap(document.body, ['onpoint'])
});
