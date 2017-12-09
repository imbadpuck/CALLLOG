app.controller('SignInController', ['$scope', '$rootScope', '$state', '$http', '$window', 'toastr', 'Auth', '$uibModal', 'CODE_STATUS',
  function ($scope, $rootScope, $state, $http, $window, toastr, Auth, $uibModal, CODE_STATUS) {

  $scope.signIn = function () {
    NProgress.start();
    Auth.signIn($scope.username, $scope.password).then(function(response) {
      NProgress.done();
      if(response.data.code == $rootScope.CODE_STATUS.success) {
        $rootScope.currentUser     = response.data.data.user;
        $http.defaults.headers.common["Authorization"] = 'Bearer ' + response.data.data.token;
        $window.localStorage.user  = JSON.stringify(response.data.data.user);
        $window.localStorage.token = response.data.data.token;
        $state.go("main");
      } else {
        toastr.error(response.data.message)
      }
    });
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
