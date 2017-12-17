app.controller('CreateTicketController', ['$scope', 'toastr', '$state', 'Ticket_API', '$rootScope', 'working_groups',
  function($scope, toastr, $state, Ticket_API, $rootScope, working_groups) {

  $scope.new_ticket = {ticket: {}, post: {}};

  $scope.makeTreeGroups = function() {
    // $scope.tree_groups = $scope.groups_data;
    // $scope.employees   = $scope.groups_data.employees;
    $.each($scope.tree_groups, function(k, v) {
      v.children = [];
      v.text     = v.name;
      v.type     = 'group';
      v.icon     = 'fa fa-group';
    });
    $.each($scope.tree_groups, function(i, group) {
      $.each($scope.tree_groups, function(k, group_2) {
        if (k != i && group_2.id == group.parent_id) {
          group_2.children.push(group);
        }
      });
    });
    $.each($scope.tree_groups, function(k, v) {
      v.children.sort(function(x, y) {
        return x.lft - y.lft;
      });
    });

    // return nodes with min depth
    var min_depth = Math.min.apply(null, _.map($scope.tree_groups, function(x) {
      return x.depth;
    }));
    $scope.tree_groups = $scope.tree_groups.filter(function(x) {
      return x.depth == min_depth;
    })[0];

    $('#tree_groups').jstree({
      core: {
        data: $scope.tree_groups.children
      }
    });

    $('#tree_groups').on("select_node.jstree", function (e, data) {
      $scope.new_ticket.ticket.group_id      = data.node.original.id;
      $scope.new_ticket.ticket.group_name    = data.node.original.name;
      $scope.new_ticket.ticket.assigned_user = '';
      $scope.$apply();
    });
  }

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
    $scope.new_ticket.ticket.begin_date = period[0].trim();
    $scope.new_ticket.ticket.deadline = period[1].trim();
  });

  $('input[id="ticket-period-of-work"]').on('cancel.daterangepicker', function(ev, picker) {
    $(this).val('');
    delete $scope.new_ticket.ticket.begin_date;
    delete $scope.new_ticket.ticket.deadline;
  });

  $scope.loadEmployees = function() {
    // if ($scope.new_ticket.ticket.assigned_user_type == 'Technician')
    //   Employee_API.getTechnicians().success(function(response) {
    //     $scope.employees = response.data;
    //   });
    // else
    //   Employee_API.getCashiers().success(function(response) {
    //     $scope.employees = response.data;
    //   });
  }

  $scope.createTicket = function() {
    NProgress.start();
    Ticket_API.createTicket($scope.new_ticket, $scope.$files).success(function(response) {
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

  $scope.clearSelectedGroup = function() {
    $('#tree_groups').jstree("deselect_all");
    $scope.new_ticket.ticket.group_id = '';
    $scope.new_ticket.ticket.group_name = '';
  }

  if ($rootScope.enableFunction('assign_request_to_working_group')) {
    $scope.tree_groups = working_groups.groups;
    $scope.makeTreeGroups();
  }

  // $repeater.repeater({
  //   show: function () {
  //     $(this).slideDown();
  //   },
  //   hide: function (remove) {
  //     if(confirm('Are you sure you want to remove this item?')) {
  //       $(this).slideUp(remove);
  //     }
  //   }
  // });
}]);
