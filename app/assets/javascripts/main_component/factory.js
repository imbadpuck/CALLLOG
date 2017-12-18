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
.factory('Group_API', ['$http', function($http){
  return {
    getGroups: function(params) {
      return $http({
        method: 'GET',
        url: '/api/v1/groups',
        params: {
          function_label: params.function_label,
        }
      });
    },
    getGroupNotJoinedUsers: function(filter_user) {
      return $http({
        url: '/api/v1/group_users/get_group_not_joined_users',
        method: 'GET',
        params: {
          filter: filter_user
        }
      });
    },
    createGroup: function(group) {
      return $http.post('/api/v1/groups', {group: group});
    },
    createGroupUsers: function(params) {
      return $http.post('/api/v1/group_users', {group_id: params.group_id, users: params.users})
    },
    deleteGroupUser: function(user_id) {
      return $http.delete("/api/v1/group_users/" + user_id);
    },
    deleteGroup: function(group_id) {
      return $http.delete("/api/v1/groups/" + group_id);
    },
    loadEmployeesForAssignedUser: function(params) {
      return $http({
        url: '/api/v1/groups/assigned_user_in_group_preload',
        method: 'GET',
        params: {
          group_id: params.group_id,
          keyword: params.keyword
        }
      });
    },
    loadRelatedUser: function(params) {
      return $http({
        url: '/api/v1/users/get_related_users',
        method: 'GET',
        params: {
          keyword: params.keyword
        }
      });
    }
  }
}])
.factory('User_API', ['$http', function($http){
  return {
    getUsers: function(params) {
      return $http({
        method: "GET",
        url: "/api/v1/users/",
        params: params
      });
    },
  }
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
    getTicketGroup: function(params) {
      return $http({
        method: 'GET',
        url: '/api/v1/groups',
        params: {
          function_label: params.function_label,
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
    createTicket: function(new_ticket, files) {
      new_ticket = JSON.stringify(new_ticket);
      var formData = new FormData();
      formData.append('new_ticket', new_ticket);
      $.each(files, function(i, file){
        formData.append('attachments[]', file);
      });
      return $http.post('/api/v1/tickets', formData, {headers: {'Content-Type': undefined}});
    },
  }
}]);
