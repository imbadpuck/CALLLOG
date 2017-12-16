angular.module("app.factory", [])
.factory("Auth", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    signIn: function(username, password) {
      return $http.post("/api/v1/sign_in", {username: username, password: password});
    },
    signOut: function() {
      $rootScope.currentUser = null;
      $window.localStorage.removeItem("user");
      $window.localStorage.removeItem("token");
    },
    isSignedIn: function() {
      return $rootScope.currentUser ? true : false;
    },
    changePassword: function(oldPassword, newPassword) {
      return $http.post("/api/v1/users/change_password", {
        old_password: oldPassword,
        new_password: newPassword,
      });
    }
  }
}])
.factory('Admin_API', ['$http', function($http){
  return {
    getUsers: function(params) {
      return $http({
        method: "GET",
        url: "/api/v1/users/",
        params: params
      });
    }
  }
}])
.factory('Employee_API', ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    getTicketGroup: function() {
      return $http.get('/api/v1/groups/ticket_group');
    },
  };
}])
.factory("Ticket_API", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {

  return {
    getDashboard: function(params) {
      return $http({
        method: 'GET',
        url: '/api/v1/tickets/dashboard',
        params: {
          dashboard_label: params.dashboard_label
        }
      });
    },
    getTickets: function(params) {
      return $http({
        method: 'GET',
        url: '/api/v1/tickets',
        params: {
          page: params.page || 1,
          status: params.status,
          dashboard_label: params.dashboard_label,
        }
      });
    },
    ticketsSearch: function(params) {
      return $http({
        method: 'GET',
        url: '/api/v1/tickets/search',
        params: {
          page: params.page || 1,
          keyword: params.search.keyword,
          status: params.status,
          created_at: params.search.created_at,
          closed_date: params.search.closed_date,
          dashboard_label: params.dashboard_label,
        }
      });
    },
  }
}]);
