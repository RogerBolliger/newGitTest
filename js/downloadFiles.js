
/********************** eine Variante
<div ng-app="myApp">
    <div ng-controller="MyCtrl">
        <my-download id="content" get-data="getBlob()" />
    </div>
</div>

var module = angular.module('myApp', []);
module.controller('MyCtrl', function ($scope){
    var data = {a:1, b:2, c:3};
    var json = JSON.stringify(data);
    $scope.getBlob = function(){
        return new Blob([json], {type: "application/json"});
    }
});
module.directive('myDownload', function ($compile) {
    return {
        restrict:'E',
        scope:{ getUrlData:'&getData'},
        link:function (scope, elm, attrs) {
            var url = URL.createObjectURL(scope.getUrlData());
            elm.append($compile(
                '<a class="btn" download="backup.json"' +
                    'href="' + url + '">' +
                    'Download' +
                    '</a>'
            )(scope));
        }
    };
});
*********************/
/************** andere
$http({method: 'GET', url: '/someUrl'}).
  success(function(data, status, headers, config) {
     var anchor = angular.element('<a/>');
     anchor.attr({
         href: 'data:attachment/csv;charset=utf-8,' + encodeURI(data),
         target: '_blank',
         download: 'filename.csv'
     })[0].click();

  }).
  error(function(data, status, headers, config) {
    // if there's an error you should see it here
  });

***/

