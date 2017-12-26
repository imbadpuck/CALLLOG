app.controller('MainController', ['$scope', '$rootScope', '$state',
  '$uibModal', 'Auth', '$compile', 'working_groups', 'notifications','toastr','CODE_STATUS','$uibModalStack',
  function ($scope, $rootScope, $state, $uibModal,
    Auth, $compile, working_groups, notifications,toastr,CODE_STATUS,$uibModalStack) {

  $scope.state             = $state;
  $rootScope.workingGroups = working_groups.groups;
  $scope.notifications     = notifications;

  var init = function() {
    functions = [
      {state: 'main.create_ticket', function_label: 'create_ticket', argument: ''},
      {state: 'main.manage_group' , function_label: 'manage_group' , argument: ''},
      {state: 'main.user_index'   , function_label: 'user_index'   , argument: ''},
      {
        state: "main.ticket_dashboard.list",
        function_label: 'own_request_dashboard',
        argument: {dashboard_label: 'own_request_dashboard', status: 'all'}
      },
      {
        state: "main.ticket_dashboard.list",
        function_label: 'related_request_dashboard',
        argument: {dashboard_label: 'related_request_dashboard', status: 'all'}
      },
    ]

    var exit = false;
    for (var i = 0; i < functions.length; i++) {
      if (exit) break;
      for (var j = 0; j < $rootScope.functionSystems.length; j++) {
        if (functions[i].function_label == $rootScope.functionSystems[j].label) {
          $state.go(functions[i].state, functions[i].argument);
          exit = true;
          break;
        }
      }
    }
  }

  $rootScope.enableFunction = function(function_label) {
    var currentFunction = null;
    for (var i = 0; i < $rootScope.functionSystems.length; i++) {
      if ($rootScope.functionSystems[i].label == function_label) {
        currentFunction = $rootScope.functionSystems[i];
      }
    }

    if (currentFunction != null) {
      for (var i = 0; i < $rootScope.functionSystems.length; i++) {
        if ($rootScope.functionChecking({
            label: function_label,
            function: currentFunction,
            node: {
              lft: $rootScope.functionSystems[i].lft,
              rgt: $rootScope.functionSystems[i].rgt
            }})) return true;
      }
    }

    return false;
  }

  $rootScope.functionChecking = function(data) {

    if(data.label == data.function.label || data.label == 'function_root' ||
      $rootScope.currentFunctionIsChildOf({c_func: data.function, e_func: data.node})) {

      return true;
    }

    return false;
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

  $scope.showChangePassword = function(params) {
    var modalInstance = $uibModal.open({
      scope: $scope,
      templateUrl: '/templates/change_password.html',
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
      if(response.code == 1) {
        $rootScope.currentUser   = response.data

      $state.reload($state.current)
        $uibModalStack.dismissAll();
      } else {
        toastr.error(response.data.message)
      }
    });
  }  

  $scope.signOut = function() {
    Auth.signOut();
    $state.go('signin');
  }

  $scope.cloneObject = function(json) {
    return JSON.parse(JSON.stringify(json));
  }

  init();

}]);
