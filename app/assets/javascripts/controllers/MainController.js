app.controller('MainController', ['$scope', '$rootScope', '$state', '$uibModal', 'Auth', '$compile',
  function ($scope, $rootScope, $state, $uibModal, Auth, $compile) {

  $scope.state = $state;

  if($state.current.name == 'main') {
    if($rootScope.currentUser.type == 'Admin') {
      $state.go('main.admin_users');
    } else if($rootScope.currentUser.type == 'Employee') {

    }
  }

  $scope.home_state = {
    Admin: 'main.admin_users',
    Employee: 'main.admin_users'
  };

  $scope.changePassword = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: '/templates/change_password.html',
      controller: ['$scope', '$uibModalInstance', 'toastr', function ($scope, $uibModalInstance, toastr) {
        NProgress.done();
        $scope.changePassword = function () {
          NProgress.start();
          Auth.changePassword($scope.oldPassword, $scope.newPassword).success(function (response) {
            NProgress.done();
            if(response.code == $rootScope.CODE_STATUS.success) {
              $uibModalInstance.dismiss();
              toastr.success(response.message);
            } else {
              toastr.error(response.message);
            }
          });
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.signOut = function() {
    Auth.signOut();
    $state.go('signin');
  }

  $scope.cloneObject = function(json) {
    return JSON.parse(JSON.stringify(json));
  }

}]);
