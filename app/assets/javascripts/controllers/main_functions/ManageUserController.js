app.controller('ManageUserController', ['$scope', '$state', 'user_list','$uibModal','$http','Auth','$rootScope','toastr',
  function ($scope, $state, user_list,$uibModal,$http,Auth,$rootScope,toastr) {

  $scope.users       = user_list.data;
  $scope.currentPage = $state.params.page || 1;

  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }

  $scope.createUser = function() {
    var modalInstance = $uibModal.open({
      scope: $scope,
      templateUrl: '/templates/users/create.html'
    });
  }
  $scope.addUser = function(newUser) {
        $scope.user = newUser
    
        if ($scope.user.status == 'active')
                $scope.user.status = 0
        else
                $scope.user.status = 1

        if(angular.isString($scope.user.gender)){
                if ($scope.user.gender == 'male')
                      $scope.user.gender = 0
                else if ($scope.user.gender == 'female')
                       $scope.user.gender = 1
                else 
                        $scope.user.gender = 2          
        }
    NProgress.start();
    var file = $scope.user.avatar;
    delete $scope.user.avatar;
    Auth.addUser($scope.user,file).success(function(response) {
      NProgress.done();
      $state.go($state.current, {page: $scope.currentPage})
    });
  }

  $scope.showUser = function(params) {
    var modalInstance = $uibModal.open({
      scope: $scope,
      templateUrl: '/templates/users/show.html',
      controller: ['$scope', '$uibModalInstance', function ($scope, $uibModalInstance) {

        $scope.user = params;

        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }  
  
  $scope.editUserPage = function(params) {
    var modalInstance = $uibModal.open({
      scope: $scope,
      templateUrl: '/templates/users/edit.html',
      controller: ['$scope', '$uibModalInstance', function ($scope, $uibModalInstance) {
        $scope.clone =params
        $scope.clone.birthdate = new Date($scope.clone.birthdate)
        $scope.newUser = $scope.clone

        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.editUser = function(newUser) {
        $scope.editUser = newUser
    
        if ($scope.editUser.status == 'active')
                $scope.editUser.status = 0
        else
                $scope.editUser.status = 1

        if(angular.isString($scope.editUser.gender)){
                if ($scope.editUser.gender == 'male')
                      $scope.editUser.gender = 0
                else if ($scope.editUser.gender == 'female')
                       $scope.editUser.gender = 1
                else 
                        $scope.editUser.gender = 2          
        }
    NProgress.start();
    var file = $scope.editUser.avatar;
    delete $scope.editUser.avatar;
    Auth.editUser($scope.editUser,file).success(function(response) {
      NProgress.done();
      $state.reload($state.current)
    });
  }
}])
