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
