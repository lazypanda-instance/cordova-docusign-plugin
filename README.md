# cordova-docusign-plugin
# docuSign_Plugin
docuSign iOS plugin for cordova application

To add docuSign plugin in your app, you need to run this following command from your terminal/cmd:

ionic cordova plugin add ./cordova-docusign-plugin

Your plugin has been set. Now you need to call this plugin from your .js file. 

        docuSign.launchDocuSignSDK("your_docoSign_email, your_password, sample_file_which_you_want_to_upload-sample.pdf", success, failure);

        var success = function(message) {
            console.log("DocuSign launch Successfully: ", message);
        }

        var failure = function() {
            alert("Error calling docuSign Plugin");
        }
