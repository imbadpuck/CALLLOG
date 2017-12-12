angular.module("app.directive", [])
.directive('form', function () {
  return {
    restrict: 'E',
    link: function (scope, elem, attrs, control) {
      $(elem).on("submit", function() {
        $(this).find(".ng-invalid:first").focus();
      });
    }
  };
})
.directive('datepicker', ['$timeout', function ($timeout) {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, element, attrs, ctrl) {
      function changeDate(date) {
        ctrl.$setViewValue(date);
        scope.$apply();
      }
      $timeout(function() {
        $(element).datepicker({
          format: "dd/mm/yyyy",
          language: "vi",
          autoclose: true
        })
      }, 100);
      element.bind('blur', function() {
        if(!this.value && attrs.default) {
          this.value = attrs.default;
        }
        var $this = this;
        $timeout(function() {
          changeDate($this.value);
        }, 20);
      });
    }
  };
}])
.directive('monthpicker', ['$timeout', function ($timeout) {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, element, attrs, ctrl) {
      function changeDate(date) {
        ctrl.$setViewValue(date);
        scope.$apply();
      }
      $timeout(function() {
        $(element).datepicker({
          format: "mm/yyyy",
          startView: "months",
          minViewMode: "months",
          language: "vi",
          autoclose: true
        })
      }, 100);
      element.bind('blur', function() {
        if(!this.value && attrs.default) {
          this.value = attrs.default;
        }
        var $this = this;
        $timeout(function() {
          changeDate($this.value);
        }, 20);
      });
    }
  };
}])
.directive('fileUpload', function () {
  return {
    restrict: "A",
    link: function (scope, el, attrs) {
      el.bind('change', function (event) {
        var file = event.target.files.item(0);
        if (file) {
          if(attrs.multiple) {
            scope.$files = scope.$files || [];
            scope.$files.push(file);
          } else {
            scope.$file = file;
          }
          scope.$apply();
        }
      });
    }
  };
})
.directive('fileUploadModel', function () {
  return {
    restrict: "A",
    scope: {
      model: "="
    },
    link: function (scope, el, attrs) {
      el.bind('change', function (event) {
        var file = event.target.files.item(0);
        if (file) {
          if(attrs.multiple) {
            scope.model = scope.model || [];
            scope.model.push(file);
          } else {
            scope.model = file;
          }
          scope.$apply();
        }
      });
    }
  };
})
.directive('uiTinymce', ['uiTinymceConfig', function(uiTinymceConfig) {
  uiTinymceConfig = uiTinymceConfig || {};
  var generatedIds = 0;
  return {
    require: 'ngModel',
    link: function(scope, elm, attrs, ngModel) {
      var expression, options, tinyInstance;
      // generate an ID if not present
      if (!attrs.id) {
        attrs.$set('id', 'uiTinymce' + generatedIds++);
      }
      options = {
        // Update model when calling setContent (such as from the source editor popup)
        setup: function(ed) {
          ed.on('init', function(args) {
            ngModel.$render();
          });
          // Update model on button click
          ed.on('ExecCommand', function(e) {
            ed.save();
            ngModel.$setViewValue(elm.val());
            if (!scope.$$phase) {
              scope.$apply();
            }
          });
          // Update model on keypress
          ed.on('KeyUp', function(e) {
            // console.log(ed.isDirty());
            ed.save();
            ngModel.$setViewValue(elm.val());
            if (!scope.$$phase) {
              scope.$apply();
            }
          });
        },
        mode: 'exact',
        elements: attrs.id,
      };

      if (attrs.uiTinymce) {
        expression = scope.$eval(attrs.uiTinymce);
      } else {
        expression = {};
      }

      angular.extend(options, uiTinymceConfig, expression);
      setTimeout(function() {
        tinymce.init(options);
      });


      ngModel.$render = function() {
        if (!tinyInstance) {
          tinyInstance = tinymce.get(attrs.id);
        }
        if (tinyInstance) {
          tinyInstance.setContent(ngModel.$viewValue || '');
        }
      };
    }
  };
}])
.directive('uiSrefIf', function($compile) {
  return {
    scope: {
      val: '@uiSrefVal',
      if: '=uiSrefIf'
    },
    link: function($scope, $element, $attrs) {
      $element.removeAttr('ui-sref-if');
      $compile($element)($scope);

      $scope.$watch('if', function(bool) {
        if (bool) {
          $element.attr('ui-sref', $scope.val);
        } else {
          $element.removeAttr('ui-sref');
          $element.removeAttr('href');
        }
        $compile($element)($scope);
      });
    }
  };
});
