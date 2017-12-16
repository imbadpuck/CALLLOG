app.controller('GroupsController', ['$scope', '$state', '$uibModal', '$ngBootbox',
    'toastr', 'Group_API', 'groups_data', '$rootScope',
  function ($scope, $state, $uibModal, $ngBootbox, toastr,
    Group_API, groups_data, $rootScope) {

  $scope.groupTypeTrans = function(type) {
    for (var i = 0; i < $rootScope.group_types.length; i++) {
      if ($rootScope.group_types[i].label == type) {
        return $rootScope.group_types[i].title;
      }
    }
  }

  $scope.userTypeTrans = function(type) {
    for (var i = 0; i < $rootScope.user_types.length; i++) {
      if ($rootScope.user_types[i].value == type) {
        return $rootScope.user_types[i].title;
      }
    }
  }

  $scope.convertToTreeGroup = function() {
    $scope.tree_groups = groups_data.groups;
    $.each($scope.tree_groups, function(k, v) {
      v.children = [];
      v.text     = v.name;
      v.state    = {opened: false};
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

    // Add user to group tree
    $.each(groups_data.users, function(i, user) {
      user.text = user.name;
      user.type = 'user';
      user.icon = 'fa fa-user';
      $.each($scope.tree_groups, function(k, group) {
        if (group.id == user.group_id) {
          group.children.push(user);
          return false;
        }
      });
    });

    // return nodes with min depth
    var min_depth = Math.min.apply(null, _.map($scope.tree_groups, function(x) {
      return x.depth;
    }));
    $scope.tree_groups = $scope.tree_groups.filter(function(x) {
      return x.depth == min_depth;
    });

    // remove building group and select first node
    $scope.tree_groups          = $scope.tree_groups[0].children;
    $scope.tree_groups[0].state = {
      opened: true,
      selected: true
    };
    $scope.group_selecting = $scope.tree_groups[0];
    $scope.tab_content     = 'info';
  }

  $scope.convertToTreeGroup();

  $('#tree_groups').jstree({
    core: {
      data: $scope.tree_groups
    }
  });

  $('#tree_groups').on("select_node.jstree", function (e, data) {
    $scope.group_selecting = data.node.original;
    $scope.tab_content     = 'info';
    $scope.$apply();
  });

  $scope.newGroup = function() {
    $scope.tab_content = 'new_group';
    $scope.group       = {};
  }

  $scope.newSubGroup = function(group) {
    $scope.tab_content = 'new_group';
    $scope.group       = {
      parent_id: group.id
    };
  }

  $scope.newMember = function() {
    $scope.tab_content  = 'new_member';
    $scope.select_users = [];
    $scope.filter_users = {group_id: $scope.group_selecting.id, page: 1, per_page: 10};
  }

  $scope.filterUsers = function() {
    $scope.filtered = true;
    Group_API.getGroupNotJoinedUsers($scope.filter_users).success(function(response) {
      if (response.code == $rootScope.CODE_STATUS.success) {
        $scope.unselect_users          = response.data.users;
        $scope.unselect_users_total    = response.data.total_entries;
        $scope.unselect_users_page     = response.data.page;
        $scope.unselect_users_per_page = response.data.per_page;
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.uniqueSelectUsers = function() {
    $scope.select_users = _.uniq($scope.select_users, function(user) {
      return user.id;
    });
  }

  $scope.uniqueUnselectUsers = function() {
    $scope.unselect_users = _.uniq($scope.unselect_users, function(user) {
      return user.id;
    });
  }

  $scope.selectUser = function(user) {
    $scope.select_users.push(user);
    $scope.uniqueSelectUsers();
    $scope.unselect_users.splice($scope.unselect_users.indexOf(user), 1);
  }

  $scope.unselectUser = function(user) {
    $scope.unselect_users.push(user);
    $scope.uniqueUnselectUsers();
    $scope.select_users.splice($scope.select_users.indexOf(user), 1);
  }

  $scope.unselectAllUsers = function(user) {
    $scope.select_users = [];
    $scope.filterUsers();
  }

  $scope.selectAllUsers = function() {
    $scope.filter_users.all = true;
    Group_API.getGroupNotJoinedUsers($scope.filter_users).success(function(response) {
      $scope.filter_users.all = false;
      if (response.code == 1) {
        for (var i = 0; i < response.data.users.length; i++) {
          $scope.select_users.push(response.data.users[i]);
        }
        $scope.uniqueSelectUsers();
        $scope.unselect_users = [];
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.createGroup = function() {
    NProgress.start();
    Group_API.createGroup($scope.group).success(function(response) {
      if (response.code == 1) {
        $state.reload();
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.createGroupUserValidation = function() {
    for (var i = 0; i < $scope.select_users.length; i++) {
      if ($scope.select_users[i].role_level == null) {

        return false;
      }
    }

    return true;
  }

  $scope.deleteGroup = function(group) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: '/templates/groups/delete_group.html',
      resolve: {
        group: group
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', 'Group_API', 'group',
        function ($scope, $uibModalInstance, toastr, Group_API, group) {
        NProgress.done();
        $scope.group  = group;
        $scope.delete = function() {
          NProgress.start();
          Group_API.deleteGroup(group.id).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $uibModalInstance.dismiss();
              $state.reload();
              toastr.success(response.message);
            } else {
              toastr.error(response.message);
            }
          });
        }

        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.deleteMember = function(user) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: '/templates/groups/delete_member.html',
      resolve: {
        user: user
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', 'Group_API', 'user',
        function ($scope, $uibModalInstance, toastr, Group_API, user) {
        NProgress.done();
        $scope.user = user;
        $scope.delete = function() {
          NProgress.start();
          Group_API.deleteGroupUser(user.user_id).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $uibModalInstance.dismiss();
              $state.reload();
              toastr.success(response.message);
            } else {
              toastr.error(response.message);
            }
          });
        }

        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.addUsersToGroup = function() {
    if ($scope.createGroupUserValidation()) {
      Group_API.createGroupUsers({
        group_id: $scope.group_selecting.id,
        users: $scope.select_users
      }).success(function(response) {
        if (response.code == 1) {
          $state.reload();
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    }
  }
}]);
