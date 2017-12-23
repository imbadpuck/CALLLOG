app.controller('NotificationController', ['$rootScope', '$scope', '$state', 'Notification_API', 'toastr',
  function ($rootScope, $scope, $state, Notification_API, toastr) {

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

  $scope.updateStatus = function(index) {
    var notification = $scope.notifications.notifications[index];
    if (notification.status == 'seen') return;
    Notification_API.updateStatus(notification.id).success(function(response) {
      if (response.code == $rootScope.CODE_STATUS.success) {
        $scope.notifications.notifications[index].status = 'seen';
        $scope.notifications.total_unseen -= 1;
      } else {
        toastr.error(response.message)
      }
    })
  }
}])
