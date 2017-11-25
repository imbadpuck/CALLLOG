APP_VERSION = 1;
var app = angular.module("CalllogApp",
  ['app.filter', 'app.directive', 'app.factory', 'ui.bootstrap', 'ui.router',
  'toastr', 'ngMessages', 'ngBootbox', 'anguFixedHeaderTable', 'ui.tinymce',
  'ngSanitize', 'ui.select', 'angular-clipboard', 'slick'])
.config(["$httpProvider", function ($httpProvider) {
  $httpProvider.defaults.crossDomain = true;
  $httpProvider.defaults.withCredentials = true;
}])
.config(['$stateProvider', '$urlRouterProvider', '$locationProvider', '$httpProvider',
  function ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) {
  $locationProvider.html5Mode(true);
  $httpProvider.interceptors.push(["$injector", "toastr", '$rootScope', '$window',
    function ($injector, toastr, $rootScope, $window) {
    return {
      responseError: function (rejection) {
        NProgress.done();
        if (rejection.status == 401) {
          $injector.get('$state').go("signin");
        } else {
          toastr.error(rejection.data.message || "Có lỗi xảy ra. Vui lòng F5 trình duyệt và thử lại.");
        }
      },
      request: function(config) {
        if(config.url.match(/templates.*html$/)) {
          config.url = config.url + '?v=' + APP_VERSION;
        }
        return config;
      }
    };
  }]);
  $stateProvider
  .state("signin", {
    url: "/signin",
    templateUrl: "/templates/signIn.html",
    controller: 'SignInController',
    requireSignIn: false
  })
  .state('main', {
    url: "/main",
    templateUrl: "/templates/main.html",
    resolve: {
      notifications: ['BuildingManager_API', '$stateParams', function(BuildingManager_API, $stateParams) {
        return BuildingManager_API.getNotificationsUsers($stateParams.page).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: 'MainController',
    requireSignIn: true
  });
  $urlRouterProvider.otherwise('/main');
}])
.run(['$rootScope', function($rootScope) {
  $rootScope.safeApply = function(fn) {
    var phase = this.$root.$$phase;
    if (phase == '$apply' || phase == '$digest') {
      if(fn && (typeof(fn) === 'function')) {
        fn();
      }
    } else {
      this.$apply(fn);
    }
  };
}]);
