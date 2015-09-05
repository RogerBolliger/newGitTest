app.controller("uploadFilesCtrl", ['$scope', 'uploadService', function ($scope, uploadService) {

    var rootUrl = 'http://localhost:8080/cgi-bin/cgiip.exe/WService=wsbroker1/adz/user.p?serviceName=uploadFile';

    $scope.addToFileList = function(element) {

        for (i=0; i < element.files.length; i++){
         element.files[i].progress  = 0;
         element.files[i].isSuccess = false;
         element.files[i].isCancel  = false;
         element.files[i].isError   = false;
        }
        $scope.$apply(function ($scope) {
            $scope.files = element.files;
        });
    }

    $scope.callObj = function(type, data){
      // Meldung von Server nach upload
      if (type == '1') {
        var result = data.ttWsRequest.statusText
      }
      // Upload progress
      else if (type = '2') {
        $scope.files = data;
      }
    }

    $scope.uploadFileList = function () {
        uploadService.uploadFile($scope.files,$scope.callObj);
    }

}]);

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
        /*
        ajax.addEventListener("load", completeHandler, false);
        ajax.addEventListener("error", errorHandler, false);
        ajax.addEventListener("abort", abortHandler, false);
        */
        ajax.open("POST", url);
        ajax.send(formdata);
    }

    function _(el){
        return document.getElementById(el);
    }

    function progressHandler(event){
       //console.log(event);
        file.progress = (event.loaded / event.total) * 100;
        gcallObj('2',gfiles);


        //svc.progress = "Uploaded "+event.loaded+" bytes of "+event.total;
        //_("loaded_n_total").innerHTML = "Uploaded "+event.loaded+" bytes of "+event.total;
        /*
        var percent = (event.loaded / event.total) * 100;
        _("progressBar").value = Math.round(percent);
        _("status").innerHTML = Math.round(percent)+"% uploaded... please wait";
        */
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


