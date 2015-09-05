app.controller("uploadFiles1Ctrl", ['$scope', 'FileUploader', function ($scope, FileUploader) {

    var rootUrl = 'http://localhost:8080/cgi-bin/cgiip.exe/WService=wsbroker1/adz/user.p?serviceName=uploadFile';

    $scope.uploader = new FileUploader({
        url: rootUrl
    });

    /*
    // Send the form data to the database
    $scope.OnPreinspectionSubmit = function () {
        if (confirm("Are you sure you want to save this information?")) {
            $http.post(pageBaseUrl + 'api/PreInspectionForm', $scope.formInformation).success(function (returnData) {
                $scope.uploader.formData.push({ preOpKey: returnData });
                $scope.uploader.uploadAll(); // Upload file
            });
        } else { }
    }
    */
}]);


