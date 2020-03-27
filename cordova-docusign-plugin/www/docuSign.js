/*global cordova, module*/

module.exports = {
    launchDocuSignSDK: function (name, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "DocuSign", "launchDocuSignSDK", [name]);
    }
};
