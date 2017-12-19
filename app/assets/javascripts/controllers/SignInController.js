app.controller('SignInController', ['$scope', '$rootScope', '$state', '$http', '$window', 'toastr', 'Auth', '$uibModal', 'CODE_STATUS',
  function ($scope, $rootScope, $state, $http, $window, toastr, Auth, $uibModal, CODE_STATUS) {

  $scope.signIn = function () {
    NProgress.start();
    Auth.signIn($scope.username, $scope.password).then(function(response) {
      NProgress.done();
      if(response.data.code == $rootScope.CODE_STATUS.success) {

        $rootScope.currentUser                = response.data.data.info.user;
        $rootScope.functionSystems            = response.data.data.info.function_systems;
        $rootScope.groupsInvolved             = response.data.data.info.groups;
        // $rootScope.generalInfo                = response.data.data.info;
        $http.defaults.headers.common["Authorization"] = 'Bearer ' + response.data.data.token;
        $window.localStorage.user             = JSON.stringify(response.data.data.info.user);
        $window.localStorage.groups_involved  = JSON.stringify(response.data.data.info.groups);
        $window.localStorage.function_systems = JSON.stringify(response.data.data.info.function_systems);
        $window.localStorage.general_info     = JSON.stringify(response.data.data.info);
        $window.localStorage.token            = response.data.data.token;

        $state.go("main");
      } else {
        toastr.error(response.data.message)
      }
    });
  }

  $scope.translateRole = function(type) {
    switch(type) {
      case 'sample_admin':
        return 'Quản trị viên';
      case 'sample_it_hanoi_leader':
        return 'Leader IT Hà Nội';
      case 'sample_it_danang_leader':
        return 'Leader IT Đà Nẵng';
      case 'sample_it_hanoi_sub_leader':
        return 'SubLeader IT Hà Nội';
      case 'sample_it_danang_sub_leader':
        return 'SubLeader IT Đà Nẵng';
      case 'sample_it_hanoi_employee':
        return 'Nhân viên nhóm IT Hà Nội';
      case 'sample_it_danang_employee':
        return 'Nhân viên nhóm IT Đà Nẵng';
      case 'sample_member':
        return 'Người dùng hệ thống';
    };
  }

  $scope.showSampleUser = function() {
    var modalInstance = $uibModal.open({
      size: "lg",
      scope: $scope,
      templateUrl: '/templates/sample_users.html',
      controller: ['$scope', '$uibModalInstance', 'toastr', function ($scope, $uibModalInstance, toastr) {
        $http.get("/api/v1/sample_users").success(function(response) {
          $scope.users = response.data;
        });

        $scope.select = function(user) {
          $scope.$parent.username = user.username;
          $scope.$parent.password = "12345678";
          $uibModalInstance.dismiss();
        }

        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }
}]);
