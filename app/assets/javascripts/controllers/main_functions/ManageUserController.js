app.controller('ManageUserController', ['$scope', '$state', 'user_list',
  function ($scope, $state, user_list) {

  $scope.users       = user_list.data;
  $scope.currentPage = $state.params.page || 1;

  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }
}])
