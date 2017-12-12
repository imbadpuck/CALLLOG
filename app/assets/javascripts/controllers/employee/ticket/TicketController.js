app.controller('TicketController', ['$scope', '$rootScope', '$state', 'toastr', '$uibModal', 'Ticket_API', 'Employee_API',
  function ($scope, $rootScope, $state, toastr, $uibModal, Ticket_API, Employee_API) {
  $scope.getKeys = function(object) {
    return object ? Object.keys(object) : [];
  }

  $scope.updateTicketStatus = function(status) {
    Ticket_API.adminUpdateTicketStatus([$scope.ticket.id], status).success(function(response) {
      if (response.code == 1) {
        $state.reload();
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.last_active = function(date_time) {
    var last_update  = new Date(date_time);
    var current_date = new Date();
    var diff_second  = (current_date - last_update) / 1000;
    if (diff_second < 3600)
      return parseInt(diff_second / 60) + " phút trước";
    if (diff_second < 86400)
      return parseInt(diff_second / 3600) + " giờ trưóc";
    return parseInt(diff_second / 86400) + " ngày trước";
  }

}]);
