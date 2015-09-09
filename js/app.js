// JavaScript source code
var app = angular.module("app", ['ngRoute', 'ngSanitize', 'ngCsv', 'angularFileUpload', 'ui.bootstrap', 'ngMessages','angularUtils.directives.dirPagination']);

app.config(function ($routeProvider) {

    $routeProvider
    .when('/', {controller: 'listController', templateUrl: 'partials/list.html'})
    .when('/upload', {controller: 'uploadFilesCtrl', templateUrl: 'partials/uploadFiles.html'})
    .when('/upload1', {controller: 'uploadFiles1Ctrl', templateUrl: 'partials/uploadFiles1.html'})
    .when('/google', {templateUrl: 'https://www.google.ch'})
    .otherwise({ redirectTo: '/' });

});

app.factory("userService", ['$http', '$q', function ($http, $q) {

    var svc = {};

    var rootUrl = 'http://localhost:8080/cgi-bin/cgiip.exe/WService=wsbroker1/adz/';

    svc.data = [];

    svc.getData = function (callObj,service,params) {
        var x2js = new X2JS();

        $http.get(rootUrl + service + params).then(
            function (data) {
                svc.data = x2js.xml_str2json(data.data);
                svc.data = svc.data.dsWebService;
                callObj(svc.data);
            },
            function (error) {
            }

        );
    }

    svc.getUsers = function (service, params) {
        var x2js = new X2JS();
        var defer = $q.defer();

        $http.get(rootUrl + service + params).then(
            function (data) {
                svc.data = x2js.xml_str2json(data.data);
                svc.data = svc.data.dsWebService;
                defer.resolve(svc.data);
            },
            function (error) {
                defer.reject(error);
            }

        );
        return defer.promise;
    }

    return svc;
}]);

app.controller("listController", ['$scope', '$location', '$routeParams', 'userService', function ($scope, $location, $routeParams, userService) {

    var service = 'user.p?serviceName=getUserlist';
    var params  = '';

    callObj = function (data) {
        $scope.users = data.ttBenutzer;
    }

    $scope.users = [];
    $scope.searchUsers = function () {
        params = '&searchUser=' + $scope.search;

        userService.getData(callObj, service, params);

    }

    $scope.searchUsers1 = function () {
        params = '&searchUser=' + $scope.search;
        userService.getUsers(service, params).then(
            function (data) {
                $scope.users = data.ttBenutzer;
            },
            function (error) {
            }
        );
    }

    $scope.getCsv = function () {

        csv = [];
        for (i = 0; i < $scope.users.length; ++i) {
            csv.push({a: $scope.users[i].Nachname, b: $scope.users[i].Vorname});
        }

        return csv;
    }

}]);

app.directive('helloWorld', function () {
    return {
        restrict: 'AE',
        template: '<p ng-transclude style="background-color:{{color}}">Hello {{name}}',
        scope: {
            color: '@colorAttr'
        },
        transclude: true,
        link: function (scope, element, attrs) {
            element[0].onclick = function () { element[0].style.color = 'red';}
        }

    }
})

app.directive('myDirective', function () {
    return {
        restrict: 'A',
        require: 'ngModel',
        link: function (scope, ele, attrs, ctrl) {

            // add a parser that will process each time the value is
            // parsed into the model when the user updates it.

            ctrl.$parsers.unshift(function (value) {
                alert(value);
                if (value) {
                    // test and set the validity after update.
                    var valid = value.charAt(0) == 'A' || value.charAt(0) == 'a';
                    ctrl.$setValidity('invalidAiportCode', valid);
                }

                // if it's valid, return the value to the model,
                // otherwise return undefined.
                return valid ? value : undefined;
            });


        }

    }
}

)

app.controller("searchCtrl", function () {
    this.submitSearch = function () {
        console.log(this.searchForm);

        if (this.searchForm.$valid) {
            console.log("form sent");
        } else {
            // If for, is invalid, show errors
            this.searchForm.submitted = true;
        }

    }

});
