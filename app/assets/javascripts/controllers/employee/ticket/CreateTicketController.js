app.controller('CreateTicketController', ['$scope', 'toastr', '$state', 'Ticket_API', 'Employee_API',
  function($scope, toastr, $state, Ticket_API, Employee_API) {

  $scope.admin_create_ticket = {ticket: {}, post: {}};
  $scope.translator = {
    'Technician': 'Nhân viên kỹ thuật',
    'Cashier': 'Nhân viên thu ngân'
  };

  $('input[id="ticket-period-of-work"]').daterangepicker({
    autoUpdateInput: false,
    timePicker: true,
    timePickerIncrement: 30,
    locale: {
      format: 'MM/DD/YYYY h:mm A',
      cancelLabel: 'Xóa'
    },
    ranges: {
     'Ngày hôm nay': [moment(), moment()],
     'Ngày hôm qua': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
     '7 ngày trước': [moment().subtract(6, 'days'), moment()],
     '30 ngày trước': [moment().subtract(29, 'days'), moment()],
     'Trong tháng này': [moment().startOf('month'), moment().endOf('month')],
     'Trong tháng trước': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
    }
  });

  $('input[id="ticket-period-of-work"]').on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format('MM/DD/YYYY h:mm A') + ' - ' + picker.endDate.format('MM/DD/YYYY h:mm A'));
    var period = $(this).val().split('-');
    $scope.admin_create_ticket.ticket.begin_date = period[0].trim();
    $scope.admin_create_ticket.ticket.deadline = period[1].trim();
  });

  $('input[id="ticket-period-of-work"]').on('cancel.daterangepicker', function(ev, picker) {
    $(this).val('');
    delete $scope.admin_create_ticket.ticket.begin_date;
    delete $scope.admin_create_ticket.ticket.deadline;
  });

  $scope.loadEmployees = function() {
    if ($scope.admin_create_ticket.ticket.assigned_user_type == 'Technician')
      Employee_API.getTechnicians().success(function(response) {
        $scope.employees = response.data;
      });
    else
      Employee_API.getCashiers().success(function(response) {
        $scope.employees = response.data;
      });
  }

  $scope.createTicket = function() {
    NProgress.start();
    Ticket_API.request(Ticket_API.adminCreateTicket, $scope.admin_create_ticket, $scope.$files).success(function(response) {
      NProgress.done();
      if(response.code == 1) {
        $state.reload('main.building_manager_tickets');
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.close = function() {
    $uibModalInstance.dismiss();
  }
}]);
