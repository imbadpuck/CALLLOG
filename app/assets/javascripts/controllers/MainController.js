app.controller('MainController', ['$scope', '$rootScope', '$state', '$uibModal', 'Auth', '$compile',
  function ($scope, $rootScope, $state, $uibModal, Auth, $compile) {

  $scope.state = $state;

  var init = function() {
    functions = [
      {state: 'main.user_index', function_label: 'user_index', argument: ''},
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

  init();

}]);
