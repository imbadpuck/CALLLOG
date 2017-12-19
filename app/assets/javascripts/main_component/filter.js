angular.module("app.filter", [])
.filter('number', [function() {
  return function(input) {
    return parseInt(input, 10);
  };
}])
.filter('fileName', [function() {
  return function(input) {
    if(input && input.length > 60)
      return input.replace(/(.{45}).*(.{10})/g, "$1...$2")
    else
      return input;
  };
}])
.filter('maxlength', [function() {
  return function(input, maxlength) {
    if(input && input.length > maxlength) {
      var re = new RegExp("(.{" + (maxlength - 8) + "}).*(.{5})", "g");
      return input.replace(re, "$1...$2")
    }
    else
      return input;
  };
}])
.filter('formatDate', [function() {
  return function(input) {
    return moment(input).format("DD/MM/YYYY")
  };
}])
.filter('workingGroup', [function() {
  return function(input) {
    if (input.purpose == 'working_group') return input;
  }
}])
.filter('formatDateTime', [function() {
  return function(input) {
    return moment(input).format("DD/MM/YYYY hh:mm:ss")
  };
}]);
