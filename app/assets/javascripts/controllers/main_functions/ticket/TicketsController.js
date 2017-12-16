app.controller('TicketsController', ['$scope', '$rootScope', '$state',
    '$uibModal', 'dashboard', 'Ticket_API',
  function ($scope, $rootScope, $state, $uibModal, dashboard, Ticket_API) {

  $scope.current_stat_box = $state.params.status || 'all';
  $scope.dashboard_label  = dashboard.dashboard_label;

  $scope.stat_box = {
    all:         {name: 'Tất cả'},
    new_ticket:  {name: 'Mới'},
    inprogress:  {name: 'Đang giải quyết'},
    resolved:    {name: 'Đã giải quyết'},
    out_of_date: {name: 'Quá hạn'},
    closed:      {name: 'Đã đóng'},
    cancelled:   {name: 'Hủy bỏ'}
  };

  $scope.breakpoints = [
    {
      breakpoint: 1024,
      settings: {
        slidesToShow: 3,
        slidesToScroll: 1,
        infinite: false,
        dots: true
      }
    },
    {
      breakpoint: 600,
      settings: {
        slidesToShow: 2,
        slidesToScroll: 1
      }
    },
    {
      breakpoint: 480,
      settings: {
        slidesToShow: 1,
        slidesToScroll: 1
      }
    }
  ]

  $.each(dashboard.statistical_data, function(k, v) {
    $scope.stat_box[k].value = v;
  });

  try {
    $scope.search = JSON.parse($state.params.search);
  } catch(e) {
    $scope.search = {};
  }

  $scope.change_current_stat_box = function(status) {
    if ($scope.stat_box.hasOwnProperty(status)) {
      $("#stat-box-" + $scope.current_stat_box).removeClass('start-box-shadow');
      $scope.current_stat_box = status;
      $("#stat-box-" + $scope.current_stat_box).addClass('start-box-shadow');
      $state.go('main.ticket_dashboard.list', {status: status, search: null},
      );
    }
  }

  $scope.searchTickets = function() {
    $state.go(
      'main.ticket_dashboard.list',
      {
        status: null,
        search: JSON.stringify($scope.search)
      }
    );
  }
}]);
