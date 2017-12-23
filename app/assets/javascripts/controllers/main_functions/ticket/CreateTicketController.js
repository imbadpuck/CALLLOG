app.controller('CreateTicketController', ['$scope', 'toastr', '$state', 'Ticket_API',
    '$rootScope', 'working_groups', 'Group_API',
  function($scope, toastr, $state, Ticket_API, $rootScope, working_groups, Group_API) {

  $scope.new_ticket = {
    title: null,
    priority: null,
    group_id: null,
    group_name: null,
    assigned_users: [null],
    related_users: [null],
  };

  $scope.priority_levels = [
    {title: 'Thấp'      , value: 0},
    {title: 'Trung Bình', value: 1},
    {title: 'Cao'       , value: 2},
    {title: 'Khẩn Cấp'  , value: 3}
  ]

  $(".cancel-default-behaviour").click(function(event) {
    event.preventDefault();
  });

  $scope.assigned_user_preload = [];
  $scope.related_user_preload  = [];

  $scope.addAssignedUser = function() {
    $scope.new_ticket.assigned_users.push(null);
  }

  $scope.addRelatedUser = function() {
    $scope.new_ticket.related_users.push(null);
  }

  $scope.deleteAssignedUser = function(index) {
    if (index == 0) return;
    $scope.new_ticket.assigned_users.splice(index, 1);
  }

  $scope.deleteRelatedUser = function(index) {
    if (index == 0) return;
    $scope.new_ticket.related_users.splice(index, 1);
  }

  $scope.loadEmployees = function(keyword) {
    $scope.assigned_user_preload = [];
    if (_.isNull($scope.new_ticket.group_id) ||
        _.isEmpty(keyword)) {
      return;
    } else {
      if (!$rootScope.enableFunction('assign_ticket_to_user_in_all_group')) {
        var accept_group = false;
        for (var i = 0; i < $rootScope.groupsInvolved.length; i++) {
          if ($rootScope.groupsInvolved[i].id == $scope.new_ticket.group_id)
            accept_group = true;
        }

        if (!accept_group) return;
      }
    }

    Group_API.loadEmployeesForAssignedUser({
      group_id: $scope.new_ticket.group_id,
      keyword: keyword
    }).success(function(response){
      if (response.code == $rootScope.CODE_STATUS.success) {
        $scope.assigned_user_preload = response.data;
      }
    })
  }

  $scope.loadRelatedUser = function(keyword) {
    $scope.related_user_preload = [];

    Group_API.loadRelatedUser({
      keyword: keyword
    }).success(function(response){
      if (response.code == $rootScope.CODE_STATUS.success) {
        $scope.related_user_preload = response.data;
      }
    });
  }

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
      if (data.node.original.id != $scope.new_ticket.group_id) {
        $scope.new_ticket.group_id   = data.node.original.id;
        $scope.new_ticket.group_name = data.node.original.name;
        $scope.new_ticket.assigned_users = [null];
        $scope.assigned_user_preload     = [];
      }
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
    $scope.new_ticket.begin_date = period[0].trim();
    $scope.new_ticket.deadline   = period[1].trim();
  });

  $('input[id="ticket-period-of-work"]').on('cancel.daterangepicker', function(ev, picker) {
    $(this).val('');
    delete $scope.new_ticket.begin_date;
    delete $scope.new_ticket.deadline;
  });

  $scope.createTicket = function() {
    for (var i = 0; i < $scope.new_ticket.assigned_users.length; i++) {
      if (_.isNull($scope.new_ticket.assigned_users[i])) {
        // if ($scope.new_ticket.assigned_users.length == 1) {
        //   $scope.new_ticket.assigned_users = [null];
        //   break;
        // }
        $scope.new_ticket.assigned_users.splice(i, 1);
      }
    }
    for (var i = 0; i < $scope.new_ticket.related_users.length; i++) {
      // if ($scope.new_ticket.related_users.length == 1) {
      //   $scope.new_ticket.related_users = [null];
      //   break;
      // }
      if (_.isNull($scope.new_ticket.related_users[i])) {
        $scope.new_ticket.related_users.splice(i, 1);
      }
    }

    if (_.isNull($scope.new_ticket.title) ||
        _.isNull($scope.new_ticket.group_id) ||
        _.isNull($scope.new_ticket.priority) ||
        _.isNull($scope.new_ticket.content)) {

      toastr.error("Xin vui lòng điền đầy đủ thông tin");
      return;
    }

    NProgress.start();

    Ticket_API.createTicket($scope.new_ticket, $scope.$files).success(function(response) {
      NProgress.done();
      if(response.code == $rootScope.CODE_STATUS.success) {
        $state.go(
          'main.ticket_dashboard.list',
          {dashboard_label: 'own_request_dashboard', status: 'all'
        });
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.clearSelectedGroup = function() {
    $('#tree_groups').jstree("deselect_all");
    $scope.new_ticket.group_id = '';
    $scope.new_ticket.group_name = '';
  }

  if ($rootScope.enableFunction('assign_ticket_to_working_group')) {
    $scope.tree_groups = working_groups.groups;
    $scope.makeTreeGroups();
  }
}]);
