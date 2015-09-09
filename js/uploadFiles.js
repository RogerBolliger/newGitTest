
/********** Controller für Upload **********************/
app.controller("uploadFilesCtrl", ['$scope', 'uploadService', function ($scope, uploadService) {

    var rootUrl = 'http://localhost:8080/cgi-bin/cgiip.exe/WService=wsbroker1/adz/user.p?serviceName=uploadFile';

    $scope.btnDownRates  = '';
    $scope.btnBrowse     = '';
    $scope.btnUpload     = 'false';
    $scope.btnImport     = 'false';
    $scope.btnImpLog     = 'false';
    $scope.btnProcess    = 'false';
    $scope.btnDownReport = '';

    $scope.addToFileList = function(element) {

        for (i=0; i < element.files.length; i++){
         element.files[i].progressBar  = 0;
         element.files[i].progressTxt  = '';
         element.files[i].completeTxt  = '';

         element.files[i].isSuccess = false;
         element.files[i].isCancel  = false;
         element.files[i].isError   = false;
        }
        $scope.$apply(function ($scope) {
            $scope.files = element.files;
        });
        $scope.btnUpload = '';
    }

    $scope.callObj = function(type, data){
      // Meldung von Server nach upload
      if (type == '1') {
        var result = data.ttWsRequest.statusText
      }
      // Upload progress
      else if (type = '2') {
        $scope.$apply(function($scope){
          $scope.files = data;
        });
      }
    }

    $scope.uploadFileList = function () {
        uploadService.uploadFile($scope.files,$scope.callObj);
    }

    var data = {a:1, b:2, c:3};
    var json = JSON.stringify(data);
    $scope.getBlob = function(){
        return new Blob([json], {type: "application/json"});
    }


}]);

/********** Factory für Upload **********************/
app.factory('uploadService', ['$http', function ($http) {
    var svc = {};

    var rootUrl = 'http://localhost:8080/cgi-bin/cgiip.exe/WService=wsbroker1/adz/user.p?serviceName=uploadFile';

    var gfiles;
    var gcallObj;
    var file;

    svc.uploadFile = function(files,callObj){
        var url = rootUrl;
        gfiles = files;
        file = files[0];
        gcallObj = callObj;
        // alert(file.name+" | "+file.size+" | "+file.type);
        var formdata = new FormData();
        formdata.append("file", file);
        var ajax = new XMLHttpRequest();
        ajax.upload.addEventListener("progress", progressHandler, false);
        ajax.addEventListener("load", completeHandler, false);
        ajax.addEventListener("error", errorHandler, false);
        ajax.addEventListener("abort", abortHandler, false);

        ajax.open("POST", url);
        ajax.send(formdata);
    }

    function progressHandler(event){
       //console.log(event);

        file.progressBar = Math.round((event.loaded / event.total) * 100);
        file.progressTxt = "Uploaded "+(event.loaded/1024).toFixed(0)+" bytes of "+(event.total/1024).toFixed(0);
        gcallObj('2',gfiles);

    }

    function completeHandler(event){
	    file.completeTxt = event.target.responseText;
	    file.isSuccess = true;
        gcallObj('2',gfiles);
    }
    function errorHandler(event){
	    file.isError = true;
        gcallObj('2',gfiles);
    }
    function abortHandler(event){
    	file.isCancel = true;
        gcallObj('2',gfiles);
    }

    svc.uploadfiles = function(files,callObj){

        var url = rootUrl;

        for ( var i = 0; i < files.length; i++)
        {
            var fd = new FormData();
            var x2js = new X2JS();

            fd.append("data", i);

            fd.append("file", files[i]);

            $http.post(url, fd, {

                withCredentials : false,

                headers : {
                    'Content-Type' : undefined
                },
                transformRequest : angular.identity

            })
           .success(function(data)
           {
                data = x2js.xml_str2json(data);
                data = data.dsWebService;
                callObj(data);
           })
           .error(function(data)
           {
               callObj(data);
           });
        }
    }

    return svc;

}]);

app.directive('myDownload', function ($compile) {
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
