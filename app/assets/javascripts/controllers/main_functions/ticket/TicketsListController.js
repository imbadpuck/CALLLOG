app.controller('TicketsListController', ['$scope', '$rootScope', '$state', '$uibModal',
  '$http', 'Ticket_API', 'toastr',
  function ($scope, $rootScope, $state, $uibModal, $http, Ticket_API, toastr) {
  $scope.loading = true;

  if ($state.params.search) {
    var search = JSON.parse($state.params.search);
    Ticket_API.ticketsSearch({
      page: $state.params.page,
      search: search,
      status: (($state.params.status || 'new_ticket')),
      dashboard_label: $scope.dashboard_label,
      group_id: $state.params.group_id
    }).success(function(response) {
      $scope.tickets_data     = response.data;
      $scope.currentPage      = $scope.tickets_data.page;
      $scope.current_stat_box = $state.params.status;
      // $.each($scope.tickets_data.box, function(k, v) {
      //   $scope.stat_box[k].value = v;
      // });
      // $scope.selects = {count_ids: 0, all: 0};
      $scope.loading = false;
    });
  } else {
    Ticket_API.getTickets({
      page: $state.params.page,
      status: (($state.params.status || 'new_ticket')),
      dashboard_label: $scope.dashboard_label,
      group_id: $state.params.group_id
    }).success(function(response) {
      $scope.tickets_data     = response.data;
      $scope.currentPage      = $scope.tickets_data.page;
      $scope.current_stat_box = $state.params.status;
      // $.each($scope.tickets_data.box, function(k, v) {
      //   $scope.stat_box[k].value = v;
      // });
      // $scope.selects = {count_ids: 0, all: 0};
      $scope.loading = false;
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

  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }

  // $scope.applySelects = function(ticket_id) {
  //   if (ticket_id == 'all') {
  //     if ($scope.selects.all) {
  //       for(var i = 0; i < $scope.tickets_data.tickets.length; i++) {
  //         $scope.selects[$scope.tickets_data.tickets[i].id] = true;
  //       }
  //       $scope.selects.count_ids = $scope.tickets_data.tickets.length;
  //     } else {
  //       for(var i = 0; i < $scope.tickets_data.tickets.length; i++) {
  //         $scope.selects[$scope.tickets_data.tickets[i].id] = false;
  //       }
  //       $scope.selects.count_ids = 0;
  //     }
  //   } else {
  //     if ($scope.selects[ticket_id]) $scope.selects.count_ids++;
  //     else $scope.selects.count_ids--;
  //   }
  // }

  // $scope.updateTicketStatus = function(status) {
  //   var ids = [];
  //   $.each($scope.selects, function(k, v) {
  //     if (k != 'count_ids' && k != 'all' && v == 1) ids.push(k);
  //   });

  //   Ticket_API.adminUpdateTicketStatus(ids, status).success(function(response) {
  //     if (response.code == 1) {
  //       $state.reload();
  //       toastr.success(response.message);
  //     } else {
  //       toastr.error(response.message);
  //     }
  //   });
  // }

  // $scope.toggleCreationTicketTemplate = function() {
  //   $('#building-manager-create-ticket').collapse('toggle');
  // }
}]);
