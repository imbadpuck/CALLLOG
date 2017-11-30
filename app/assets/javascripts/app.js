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
    controller: 'MainController',
    requireSignIn: true
  });
  $urlRouterProvider.otherwise('/main');
}])
.run(['$state', '$window', '$http', '$rootScope', '$timeout', 'Auth',
  function ($state, $window, $http, $rootScope, $timeout, Auth) {
  Layout.init();
  App.init();
  NProgress.configure({
    template: '<div class="bar" role="bar"><div class="peg"></div></div>\
              <div class="page-spinner-bar">\
                  <div class="bounce1"></div>\
                  <div class="bounce2"></div>\
                  <div class="bounce3"></div>\
              </div>'
  });

  NProgress.start();
  if($window.localStorage.token) {
    $rootScope.currentUser = JSON.parse($window.localStorage.user);
    if ($window.localStorage.menu) {
      $rootScope.menu = JSON.parse($window.localStorage.menu);
    } else {
      $rootScope.menu = null;
    }
    $http.defaults.headers.common["Authorization"] = 'Bearer ' + $window.localStorage.token;
    $state.go("main");
  } else {
    $state.go("signin");
  }

  $rootScope.currentYear  = currentYear;
  $rootScope.currentMonth = currentMonth;
  $rootScope.currentDate  = currentDate;
  $rootScope.common_text  = {
    validate: {
      username: "Tên đăng nhập chỉ được chứa ký tự a-z, 0-9 và dấu gạch dưới.",
      require: "Trường này không được để trống.",
      email: "Email không đúng định dạng.",
      phone: "Số điện thoại không đúng định dạng.",
      password: "Mật khẩu dài ít nhất 8 kí tự.",
      password_confirm: "Mật khẩu xác nhận không đúng."
    }
  }


  $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {
    NProgress.start();
    if (toState.requireSignIn && !Auth.isSignedIn()) {
      event.preventDefault();
      $state.go("signin");
    }
    if (toState.requireRoles) {
      event.preventDefault();
      $state.go("main");
    }
  });
  $timeout(function() {
    Layout.setAngularJsSidebarMenuActiveLink('match', null, $state);
  }, 500);
  $rootScope.$on('$stateChangeSuccess', function () {
    NProgress.done();
    Layout.setAngularJsSidebarMenuActiveLink('match', null, $state);
  });

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
