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
    resolve: {
      working_groups: ['Group_API', function(Group_API) {
        return Group_API.getGroups({function_label: 'working_group_index'}).then(function(response) {
          return response.data.data;
        });
      }],
    },
    templateUrl: "/templates/main.html",
    controller: 'MainController',
    requireSignIn: true
  })
  .state('main.user_index', {
    url: "/users?page&keyword",
    templateUrl: "/templates/users/index.html",
    resolve: {
      user_list: ['User_API', '$stateParams', function(User_API, $stateParams) {
        return User_API.getUsers({page: $stateParams.page || 1, keyword: $stateParams.keyword}).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: 'ManageUserController',
    requireSignIn: true
  })
  .state('main.manage_group', {
    url: '/groups',
    templateUrl: '/templates/groups/index.html',
    resolve: {
      groups_data: ['Group_API', function(Group_API) {
        return Group_API.getGroups({function_label: 'get_tree_group'}).then(function(response) {
          return response.data.data;
        });
      }]
    },
    controller: 'GroupsController',
    requireSignIn: true
  })
  .state('main.ticket_dashboard', {
    url: "/tickets/:dashboard_label?group_id",
    templateUrl: "/templates/tickets/index.html",
    resolve: {
      dashboard: ['Ticket_API', '$stateParams', function(Ticket_API, $stateParams) {
        return Ticket_API.getDashboard({
          dashboard_label: $stateParams.dashboard_label, group_id: $stateParams.group_id
        }).then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: 'TicketsController',
    requireSignIn: true
  })
  .state('main.create_ticket', {
    url: "/create_ticket",
    templateUrl: "/templates/tickets/new_without_modal.html",
    resolve: {
      working_groups: ['Group_API', function(Group_API) {
        return Group_API.getGroups({function_label: 'working_group_index'}).then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: 'CreateTicketController',
    requireSignIn: true
  })
  .state('main.ticket_dashboard.list', {
    url: "/list?page&status&search",
    templateUrl: "/templates/tickets/list.html",
    controller: 'TicketsListController',
    requireSignIn: true
  })
  .state('main.ticket_dashboard.show', {
    url: "/show?ticket_id",
    templateUrl: "/templates/tickets/show.html",
    controller: 'TicketController',
    requireSignIn: true
  });
  $urlRouterProvider.otherwise('/main');
}])
.run(['$state', '$window', '$http', '$rootScope', '$timeout', 'Auth', 'CODE_STATUS',
  function ($state, $window, $http, $rootScope, $timeout, Auth, CODE_STATUS) {
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
    $rootScope.currentUser     = JSON.parse($window.localStorage.user);
    $rootScope.groupsInvolved  = JSON.parse($window.localStorage.groups_involved);
    $rootScope.functionSystems = JSON.parse($window.localStorage.function_systems);
    $rootScope.generalInfo     = JSON.parse($window.localStorage.general_info);
    $http.defaults.headers.common["Authorization"] = 'Bearer ' + $window.localStorage.token;
    $state.go("main");

  } else {
    $state.go("signin");
  }
  $rootScope.server_url   = 'http://localhost:3000'

  $rootScope.CODE_STATUS  = CODE_STATUS;
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

  $rootScope.group_types = [
    {title: 'Phân loại người dùng', value: 2, label: 'classify'},
    {title: 'Nhóm làm việc'       , value: 3, label: 'working_group'}
  ]

  $rootScope.user_types = [
    {title: 'Quản trị viên', value: 'Admin'},
    {title: 'Nhân viên'    , value: 'Employee'}
  ]

  $rootScope.user_regency_in_group = [
    {title: 'Trưởng nhóm', value: 3},
    {title: 'Phó nhóm'   , value: 2},
    {title: 'Thành viên' , value: 1}
  ]

  $rootScope.currentFunctionIsParentOf = function(data) {
    if (data.c_func.lft < data.e_func.lft &&
        data.c_func.rgt > data.e_func.rgt) {
      return true;
    }

    return false;
  }

  $rootScope.currentFunctionIsChildOf = function(data) {
    return !$rootScope.currentFunctionIsParentOf(data);
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
