app.controller('TicketController', ['$scope', '$rootScope', '$state', 'toastr',
    '$uibModal', 'Ticket_API', 'ticket_data',
  function ($scope, $rootScope, $state, toastr, $uibModal, Ticket_API, ticket_data) {

  for (var i = 0; i < ticket_data.comments.length; i++) {
    ticket_data.comments[i].attachments = JSON.parse(ticket_data.comments[i].attachments)
  }

  $scope.ticket                   = ticket_data.ticket;
  $scope.creator                  = ticket_data.creator;
  $scope.ticket['assigned_users'] = _.isEmpty(ticket_data.assigned_users) ? [null] : ticket_data.assigned_users;
  $scope.ticket['related_users']  = _.isEmpty(ticket_data.related_users) ? [null] : ticket_data.related_users;
  $scope.ticket.attachments       = JSON.parse($scope.ticket.attachments);
  $scope.comments                 = ticket_data.comments || [];
  $scope.new_comment              = {};
  $scope.error                    = {};
  $scope.oldTicket                = JSON.parse(JSON.stringify($scope.ticket));

  if ($scope.ticket.creator_id == $rootScope.currentUser.id) {
    $scope.comment_function_label = 'comment_in_own_ticket';
  } else if ($state.params.dashboard_label == 'assigned_request_dashboard') {
    $scope.comment_function_label = 'comment_in_assigned_ticket';
  } else if ($rootScope.enableFunction('comment_in_all_ticket')) {
    $scope.comment_function_label = 'comment_in_all_ticket';
  } else if ($rootScope.enableFunction('comment_in_ticket_in_working_group')) {
    $scope.comment_function_label = 'comment_in_ticket_in_working_group';
  } else {
    $scope.comment_function_label = '';
  }

  $scope.new_comment = {
    content: '',
    note: null,
    attachments: []
  }

  $scope.edit_ticket_status = {
    new_ticket:  {
      name: 'Mới',
      available_status: []
    },
    inprogress:  {
      name: 'Đang giải quyết',
      available_status: []
    },
    resolved:    {
      name: 'Đã giải quyết',
      available_status: []
    },
    out_of_date: {
      name: 'Quá hạn',
      available_status: []
    },
    feedback:    {
      name: 'Đã đánh giá',
      available_status: []
    },
    closed:      {
      name: 'Đã đóng',
      available_status: []
    },
    cancelled:   {
      name: 'Hủy bỏ',
      available_status: []
    }
  }

  var getAvaiableTicketStatus = function() {
    if ($scope.creator.id == $rootScope.currentUser.id) {
      $scope.edit_ticket_status.new_ticket.available_status = [
        {name: 'Hủy bỏ', value: 6, label: 'cancelled'}
      ]
      $scope.edit_ticket_status.inprogress.available_status = [
        {name: 'Hủy bỏ', value: 6, label: 'cancelled'}
      ]
      $scope.edit_ticket_status.resolved.available_status = [
        {name: 'Đã đánh giá', value: 3, label: 'feedback'},
        {name: 'Hủy bỏ'     , value: 6, label: 'cancelled'},
        {name: 'Đã đóng'    , value: 5, label: 'closed'}
      ]
      $scope.edit_ticket_status.feedback.available_status = [
        {name: 'Hủy bỏ' , value: 6, label: 'cancelled'},
        {name: 'Đã đóng', value: 5, label: 'closed'}
      ]
    }
    if ($rootScope.enableFunction('edit_all_ticket')) {
      var available_status_array = [
        {name: 'Đang giải quyết', value: 1, label: 'inprogress'},
        {name: 'Hủy bỏ'         , value: 6, label: 'cancelled'},
      ]

      var current_array = $scope.edit_ticket_status.new_ticket.available_status;
      for (var i = 0; i < available_status_array.length; i++) {
        var available     = false;
        for (var j = 0; j < current_array.length; j++) {
          if (available_status_array[i].label == current_array[j].label) {
            available = true;
            break;
          }
        }
        if (!available) {
          $scope.edit_ticket_status.new_ticket.available_status.push(available_status_array[i])
        }
      }

      var available_status_array = [
        {name: 'Đã giải quyết', value: 2, label: 'resolved'},
        {name: 'Hủy bỏ'       , value: 6, label: 'cancelled'},
      ]

      var current_array = $scope.edit_ticket_status.inprogress.available_status;
      for (var i = 0; i < available_status_array.length; i++) {
        var available     = false;
        for (var j = 0; j < current_array.length; j++) {
          if (available_status_array[i].label == current_array[j].label) {
            available = true;
            break;
          }
        }
        if (!available) {
          $scope.edit_ticket_status.inprogress.available_status.push(available_status_array[i])
        }
      }

      var available_status_array = [
        {name: 'Đã đánh giá', value: 3, label: 'feedback'},
        {name: 'Hủy bỏ'     , value: 6, label: 'cancelled'},
        {name: 'Đã đóng'    , value: 5, label: 'closed'}
      ]

      var current_array = $scope.edit_ticket_status.resolved.available_status;
      for (var i = 0; i < available_status_array.length; i++) {
        var available     = false;
        for (var j = 0; j < current_array.length; j++) {
          if (available_status_array[i].label == current_array[j].label) {
            available = true;
            break;
          }
        }
        if (!available) {
          $scope.edit_ticket_status.resolved.available_status.push(available_status_array[i])
        }
      }

      var available_status_array = [
        {name: 'Đang giải quyết', value: 1, label: 'inprogress'},
        {name: 'Hủy bỏ'         , value: 6, label: 'cancelled'},
        {name: 'Đã đóng'        , value: 5, label: 'closed'}
      ]

      var current_array = $scope.edit_ticket_status.feedback.available_status;
      for (var i = 0; i < available_status_array.length; i++) {
        var available     = false;
        for (var j = 0; j < current_array.length; j++) {
          if (available_status_array[i].label == current_array[j].label) {
            available = true;
            break;
          }
        }
        if (!available) {
          $scope.edit_ticket_status.feedback.available_status.push(available_status_array[i])
        }
      }
    }
    for (var g = 0; g < $rootScope.groupsInvolved.length; g++) {
      if ($rootScope.groupsInvolved[g].id == $state.params.group_id &&
          $rootScope.enableFunction('edit_ticket_in_working_group')) {

        var available_status_array = [
          {name: 'Đang giải quyết', value: 1, label: 'inprogress'}
        ]

        var current_array = $scope.edit_ticket_status.new_ticket.available_status;
        for (var i = 0; i < available_status_array.length; i++) {
          var available     = false;
          for (var j = 0; j < current_array.length; j++) {
            if (available_status_array[i].label == current_array[j].label) {
              available = true;
              break;
            }
          }
          if (!available) {
            $scope.edit_ticket_status.new_ticket.available_status.push(available_status_array[i])
          }
        }

        var available_status_array = [
          {name: 'Đã giải quyết', value: 2, label: 'resolved'}
        ]

        var current_array = $scope.edit_ticket_status.inprogress.available_status;
        for (var i = 0; i < available_status_array.length; i++) {
          var available     = false;
          for (var j = 0; j < current_array.length; j++) {
            if (available_status_array[i].label == current_array[j].label) {
              available = true;
              break;
            }
          }
          if (!available) {
            $scope.edit_ticket_status.inprogress.available_status.push(available_status_array[i])
          }
        }

        var available_status_array = [
          {name: 'Đã đánh giá', value: 3, label: 'feedback'},
        ]

        var current_array = $scope.edit_ticket_status.resolved.available_status;
        for (var i = 0; i < available_status_array.length; i++) {
          var available     = false;
          for (var j = 0; j < current_array.length; j++) {
            if (available_status_array[i].label == current_array[j].label) {
              available = true;
              break;
            }
          }
          if (!available) {
            $scope.edit_ticket_status.resolved.available_status.push(available_status_array[i])
          }
        }

        var available_status_array = [
         {name: 'Đang giải quyết', value: 1, label: 'inprogress'}
        ]

        var current_array = $scope.edit_ticket_status.feedback.available_status;
        for (var i = 0; i < available_status_array.length; i++) {
          var available     = false;
          for (var j = 0; j < current_array.length; j++) {
            if (available_status_array[i].label == current_array[j].label) {
              available = true;
              break;
            }
          }
          if (!available) {
            $scope.edit_ticket_status.feedback.available_status.push(available_status_array[i])
          }
        }
      }
    }
  }

  $scope.toggleEditTicketTemplate = function() {
    $('#edit-ticket').collapse('toggle');
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

  $scope.createComment = function() {
    if (!$scope.new_comment.content) {
      $scope.error.content = true;
      return;
    } else $scope.error.content = false;
    NProgress.start();
    var files = $scope.new_comment.attachments;
    delete $scope.new_comment.attachments;

    $scope.new_comment['ticket_id'] = $scope.ticket.id;

    Ticket_API.createComment({
      new_comment: $scope.new_comment,
      comment_function_label: $scope.comment_function_label,
      files: files,
      group_id: $state.params.group_id
    }).success(function (response) {
      NProgress.done();
      if (response.code == $rootScope.CODE_STATUS.success) {
        $scope.new_comment        = {};
        response.data.attachments = JSON.parse(response.data.attachments)
        $scope.comments.push(response.data);
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.disabledItem = function(data) {
    if (_.isNull($rootScope.currentUser) ||
        _.isEmpty($rootScope.currentUser)) return;
    var active_labels      = data.active_labels;
    var disabled_labels    = data.disabled_labels;
    var active_edit_labels = [];

    if ($scope.creator.id == $rootScope.currentUser.id) {
      active_edit_labels.push('edit_own_ticket');
    }
    if ($rootScope.enableFunction('edit_all_ticket')) {
      active_edit_labels.push('edit_all_ticket');
    }
    for (var i = 0; i < $rootScope.groupsInvolved.length; i++) {
      if ($rootScope.groupsInvolved[i].id == $scope.ticket.group_id &&
          $rootScope.enableFunction('edit_ticket_in_working_group')) {
        active_edit_labels.push('edit_ticket_in_working_group');
      }
    }

    if (Array.isArray(active_labels)) {
      for (var i = 0; i < active_labels.length; i++) {
        for (var j = 0; j < active_edit_labels.length; j++) {
          if (active_edit_labels[j] == active_labels[i]) {
            return true;
          }
        }
      }
    } else if (Array.isArray(disabled_labels)) {

      active_edit_labels.removeIf(function(e, i) {
        return disabled_labels.indexOf(e) != -1;
      });

      if (active_edit_labels.length > 0) return true;
    }

    return false;
  }

  getAvaiableTicketStatus();
}]);
