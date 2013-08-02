function HomeCtrl($scope) {
  console.log($scope);
}

function RawCtrl($scope, $location, $http) {
  $scope.updateFilename = function(ele) {
    $scope.filename = ele.value.substring(ele.value.lastIndexOf('\\') + 1);
    $scope.$apply();
  };

  $scope.items = [ 1 ];
  $scope.addControl = function() {
    console.log($scope);
    $scope.items.push(1);
  };

  $scope.deleteRun = function() {
    $http.get('b/deleteRunById', {
      params : {
        runId : $scope.run
      }
    }).success(function() {
      $location.path('/');
      $scope.$apply();
    });
  };
}

function DisplayController($scope, $location, $http) {
  $scope.hours = [];
  $scope.rows = [];
  $scope.controls = [];
  $scope.showingData = false;
  $scope.loading = false;
  $scope.loaded = false;
  $scope.run = -1;

  $scope.encodeUrl = function(str) {
    return encodeURIComponent(str);
  };

  $scope.getControls = function() {
    $scope.loaded = false;

    $http.get('b/getRawDataControlsForRun', {
      params : {
        runId : $scope.run
      }
    }).success(function(data) {
      $scope.controls = data;
      $scope.showingData = false;
      $scope.hours = [];
      $scope.rows = [];
    });
  };

  $scope.getNormalizedData = function() {
    if ($scope.loaded) {
      $scope.showingData = !$scope.showingData;
    } else {
      $scope.showingData = false;
      $scope.loading = true;
      $scope.hours = [];
      $scope.rows = [];

      $http.get('b/getNormalizedData', {
        params : {
          runId : $scope.run,
          func : $scope.func
        }
      }).success(function(data) {
        var time = {};
        var tableRows = {};

        $.each(data, function() {
          var key = this.plateName + '_' + this.geneId;
          if (tableRows[key] == undefined) {
            tableRows[key] = {
              plate : this.plateName,
              gene : this.geneId,
              data : []
            };
            $scope.rows.push(tableRows[key]);
          }
          tableRows[key].data.push(this.normalized);
          time['_' + this.timeMarker] = true;
        });

        for (key in time) {
          $scope.hours.push(key.substring(1) + 'hr');
        }

        $scope.showingData = true;
        $scope.loading = false;
        $scope.loaded = true;
      });
    }
  };

  $scope.getZFactor = function() {
    if ($scope.loaded) {
      $scope.showingData = !$scope.showingData;
    } else {
      $scope.showingData = false;
      $scope.loading = true;
      $scope.hours = [];
      $scope.rows = [];

      $http.get('b/getZFactorData', {
        params : {
          runId : $scope.run,
          func : $scope.func
        }
      }).success(function(data) {
        var time = {};
        var tableRows = {};

        $.each(data, function() {
          var key = this.plateName + '_' + this.geneId;
          if (tableRows[key] == undefined) {
            tableRows[key] = {
              plate : this.plateName,
              data : []
            };
            $scope.rows.push(tableRows[key]);
          }
          tableRows[key].data.push(this.zFactor);
          time['_' + this.timeMarker] = true;
        });

        for (key in time) {
          $scope.hours.push(key.substring(1) + 'hr');
        }

        $scope.showingData = true;
        $scope.loading = false;
        $scope.loaded = true;
      });
    }
  };

  $scope.getViabilityData = function() {
    if ($scope.loaded) {
      $scope.showingData = !$scope.showingData;
    } else {
      $scope.showingData = false;
      $scope.loading = true;
      $scope.hours = [];
      $scope.rows = [];

      $http.get('b/getViabilityData', {
        params : {
          runId : $scope.run,
          func : $scope.func
        }
      }).success(function(data) {
        $.each(data, function() {
          $scope.rows.push({
            plate : this.plateName,
            gene : this.geneId,
            data : this.normalized
          });
        });

        $scope.showingData = true;
        $scope.loading = false;
        $scope.loaded = true;
      });
    }
  };
}

var app = angular.module('bio', []).config(function($routeProvider) {
  $routeProvider.when('/', {
    templateUrl : 'home.html'
  }).when('/rawUpload', {
    templateUrl : 'b/rawUpload'
  }).when('/viabilityUpload', {
    templateUrl : 'b/viabilityUpload'
  }).when('/deleteRun', {
    templateUrl : 'b/deleteRun'
  }).when('/viewNormalizedData', {
    templateUrl : 'b/viewNormalizedData'
  }).when('/viewZFactor', {
    templateUrl : 'b/viewZFactor'
  }).when('/viewViability', {
    templateUrl : 'b/viewViability'
  }).otherwise({
    redirectTo : '/'
  });
});

app.directive('uploadForm', function factory($location) {
  return function preLink($scope, iElement, iAttrs) {
    $scope.upload = function() {
      var formData = new FormData($('form')[0]);
      $.ajax({
        url : $(iElement).attr('destination'),
        type : 'POST',
        data : formData,
        cache : false,
        contentType : false,
        processData : false,
        success : function(data) {
          $location.path($(iElement).attr('returnPath'));
          $scope.$apply();
        },
        error : errorHandler = function() {
          console.log("N�got gick fel");
        }
      });
    };
  };
});