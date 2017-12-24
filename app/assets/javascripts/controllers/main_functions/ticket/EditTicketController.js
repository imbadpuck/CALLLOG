app.controller('EditTicketController', ['$scope', 'toastr', '$state', 'Ticket_API',
    '$rootScope', 'Group_API',
  function($scope, toastr, $state, Ticket_API, $rootScope, Group_API) {

  $scope.priority_levels = [
    {title: 'Thấp'      , value: 0},
    {title: 'Trung Bình', value: 1},
    {title: 'Cao'       , value: 2},
    {title: 'Khẩn Cấp'  , value: 3}
  ]

  $scope.assigned_user_preload = [];
  $scope.related_user_preload  = [];
  $scope.add_comment_for_update_ticket = false;

  $scope.add_comment_for_update_ticketIfTicketPropertiesChanged = function() {
    if ($scope.ticket.status != $scope.oldTicket.status) {
      $scope.add_comment_for_update_ticket = true;
    } else if ($scope.ticket.begin_date != scope.oldTicket.begin_date ||
               $scope.ticket.deadline != scope.oldTicket.deadline) {
      $scope.add_comment_for_update_ticket = true;
    } else if (!_.isEmpty($scope.ticket.rating)) {
      $scope.add_comment_for_update_ticket = true;
    }

    return $scope.add_comment_for_update_ticket;
  }

  $scope.addAssignedUser = function() {
    $scope.ticket.assigned_users.push(null);
  }

  $scope.addRelatedUser = function() {
    $scope.ticket.related_users.push(null);
  }

  $scope.deleteAssignedUser = function(index) {
    if (index == 0) return;
    $scope.ticket.assigned_users.splice(index, 1);
  }

  $scope.deleteRelatedUser = function(index) {
    if (index == 0) return;
    $scope.ticket.related_users.splice(index, 1);
  }

  $scope.loadEmployees = function(keyword) {
    $scope.assigned_user_preload = [];
    if (_.isNull($scope.ticket.group_id) ||
        _.isEmpty(keyword)) {
      return;
    } else {
      if (!$rootScope.enableFunction('assign_ticket_to_user_in_all_group')) {
        var accept_group = false;
        for (var i = 0; i < $rootScope.groupsInvolved.length; i++) {
          if ($rootScope.groupsInvolved[i].id == $scope.ticket.group_id)
            accept_group = true;
        }

        if (!accept_group) return;
      }
    }

    Group_API.loadEmployeesForAssignedUser({
      group_id: $scope.ticket.group_id,
      keyword: keyword
    }).success(function(response){
      if (response.code == $rootScope.CODE_STATUS.success) {
        $scope.assigned_user_preload = response.data;
      }
    })
  }

  $scope.getPriorityTitle = function(ticket_priority) {
    switch(ticket_priority) {
      case 'low':
        $scope.ticket.priority = 0;
        return 'Thấp';
      case 'medium':
        $scope.ticket.priority = 1;
        return 'Trung Bình';
      case 'high':
        $scope.ticket.priority = 2;
        return 'Cao';
      case 'imminent':
        $scope.ticket.priority = 3;
        return 'Khẩn Cấp';
    }
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

    var checkExist = setInterval(function() {
      if ($('#tree_groups_edit_ticket').length > 0) {
        $('#tree_groups_edit_ticket').jstree({
          core: {
            data: $scope.tree_groups.children
          }
        });

        $('#tree_groups_edit_ticket').on("select_node.jstree", function (e, data) {
          if (data.node.original.id != $scope.ticket.group_id) {
            $scope.ticket.group_id       = data.node.original.id;
            $scope.ticket.group_name     = data.node.original.name;
            $scope.ticket.assigned_users = [null];
            $scope.assigned_user_preload = [];
          }
          $scope.$apply();
        });
        clearInterval(checkExist);
      }
    }, 100);
  }

  var checkExist = setInterval(function() {
    if ($(".cancel-default-behaviour").length > 0) {

      $(".cancel-default-behaviour").click(function(event) {
        event.preventDefault();
      });

      clearInterval(checkExist);
    }
  }, 100);

  var checkExist = setInterval(function() {
    var startDate = null;
    var endDate   = null;
    var config    = {
      autoUpdateInput: false,
      timePicker: true,
      timePickerIncrement: 30,
      locale: {
        format: 'YYYY-MM-DD h:mm A',
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
    }

    if (!_.isNull($scope.ticket.deadline)) {
      var endDate           = new Date($scope.ticket.deadline);
      config['endDate'] = endDate.getFullYear() + '-' +
        endDate.getMonth() + '-' + endDate.getDay();

    }

    if (!_.isNull($scope.ticket.begin_date)) {
      var startDate           = new Date($scope.ticket.begin_date);
      config['startDate'] = startDate.getFullYear() + '-' +
        startDate.getMonth() + '-' + startDate.getDay();
    }

    if ($('input[id="edit-ticket-period-of-work"]').length) {
          $('input[id="edit-ticket-period-of-work"]').daterangepicker(config);

      $('input[id="edit-ticket-period-of-work"]').on('apply.daterangepicker', function(ev, picker) {
        $(this).val(picker.startDate.format('MM/DD/YYYY h:mm A') + ' - ' + picker.endDate.format('MM/DD/YYYY h:mm A'));
        var period = $(this).val().split('-');
        $scope.ticket.begin_date = period[0].trim();
        $scope.ticket.deadline   = period[1].trim();
      });

      $('input[id="edit-ticket-period-of-work"]').on('cancel.daterangepicker', function(ev, picker) {
        $(this).val('');
        delete $scope.ticket.begin_date;
        delete $scope.ticket.deadline;
      });
      clearInterval(checkExist);
    }
  }, 100);

  $scope.editTicket = function() {
    for (var i = 0; i < $scope.ticket.assigned_users.length; i++) {
      if (_.isNull($scope.ticket.assigned_users[i])) {
        // if ($scope.ticket.assigned_users.length == 1) {
        //   $scope.ticket.assigned_users = [null];
        //   break;
        // }
        $scope.ticket.assigned_users.splice(i, 1);
      }
    }
    for (var i = 0; i < $scope.ticket.related_users.length; i++) {
      // if ($scope.ticket.related_users.length == 1) {
      //   $scope.ticket.related_users = [null];
      //   break;
      // }
      if (_.isNull($scope.ticket.related_users[i])) {
        $scope.ticket.related_users.splice(i, 1);
      }
    }

    if (_.isNull($scope.ticket.title) ||
        _.isNull($scope.ticket.group_id) ||
        _.isNull($scope.ticket.priority) ||
        _.isNull($scope.ticket.content)) {

      toastr.error("Xin vui lòng điền đầy đủ thông tin");
      return;
    }

    if ($scope.add_comment_for_update_ticket ||
        _.isEmpty($scope.new_comment_for_update_ticket)) return;

    NProgress.start();

    var files = $scope.ticket.attachments;
    delete $scope.ticket.attachments;

    Ticket_API.editTicket(
      $scope.ticket, files,
      $scope.new_comment_for_update_ticket).success(function(response) {
      NProgress.done();
      if(response.code == $rootScope.CODE_STATUS.success) {
        $state.reload($state.current);
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.clearSelectedGroup = function() {
    $('#tree_groups_edit_ticket').jstree("deselect_all");
    $scope.ticket.group_id   = '';
    $scope.ticket.group_name = '';
  }

  $scope.tree_groups = $rootScope.workingGroups;
  $scope.makeTreeGroups();
}]);
