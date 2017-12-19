app.controller('TicketController', ['$scope', '$rootScope', '$state', 'toastr',
    '$uibModal', 'Ticket_API',
  function ($scope, $rootScope, $state, toastr, $uibModal, Ticket_API) {

  $scope.new_comment = {
    content: '',
    note: null,
    attachments: []
  }

  $scope.loadEmployees = function(keyword) {
    $scope.assigned_user_preload = [];
    if (_.isNull($scope.new_ticket.ticket.group_id)) {
      return;
    } else {
      if (!$rootScope.enableFunction('assign_ticket_to_user_in_all_group')) {
        var accept_group = false;
        for (var i = 0; i < $rootScope.groupsInvolved.length; i++) {
          if ($rootScope.groupsInvolved[i].id == $scope.new_ticket.ticket.group_id)
            accept_group = true;
        }

        if (!accept_group) return;
      }
    }

    Group_API.loadEmployeesForAssignedUser({
      group_id: $scope.new_ticket.ticket.group_id,
      keyword: keyword
    }).success(function(response){
      if (response.code == $rootScope.CODE_STATUS.success) {
        $scope.assigned_user_preload = response.data;
      }
    })
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
    var comment_function_label = null;
    delete $scope.new_comment.attachments;

    if ($scope.ticket.creator_id == $rootScope.currentUser.id) {
      comment_function_label = 'comment_in_own_ticket';
    } else if ($state.params.dashboard_label == 'assigned_request_dashboard') {
      comment_function_label = 'comment_in_own_ticket';
    } else if ($rootScope.enableFunction('comment_in_all_ticket')) {
      comment_function_label = 'comment_in_all_ticket';
    } else if ($rootScope.enableFunction('comment_in_ticket_in_group')) {
      comment_function_label = 'comment_in_ticket_in_group';
    }

    $scope.new_comment['ticket_id'] = $scope.ticket.id;

    Ticket_API.createComment({
      new_comment: $scope.new_comment,
      comment_function_label: comment_function_label,
      files: files
    })
      .success(function (response) {
      NProgress.done();
      if (response.code == $rootScope.CODE_STATUS.success) {
        $scope.new_comment        = {};
        response.data.attachments = JSON.parse(response.data.attachments)
        $scope.comments.push(response.data);
        // $state.reload($state.current, {
        //   ticket_id: $state.params.ticket_id,
        //   dashboard_label: $state.params.dashboard_label
        // })
      } else {
        toastr.error(response.message);
      }
    });
  }

  Ticket_API.getTicket({
    ticket_id: $state.params.ticket_id,
    dashboard_label: $state.params.dashboard_label
  }).success(function(response) {
    for (var i = 0; i < response.data.comments.length; i++) {
      response.data.comments[i].attachments =
        JSON.parse(response.data.comments[i].attachments)
    }
    $scope.ticket                   = response.data.ticket;
    $scope.creator                  = response.data.creator;
    $scope.ticket['assigned_users'] = response.data.assigned_users;
    $scope.ticket['related_users']  = response.data.related_users;
    $scope.ticket.attachments       = JSON.parse($scope.ticket.attachments);
    $scope.comments                 = response.data.comments;
    $scope.new_comment              = {};
    $scope.error                    = {};
    // $scope.loadEmployees('');
  });

}]);
