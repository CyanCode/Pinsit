Parse.Cloud.define("verifyNumber", function(request, response) {
    var twilio = require("twilio");
    twilio.initialize("AC90b7d2008703ddfb9c8acc3274c1d924", "9968159162bcf90e1c63c2860c0a0847");
  
    twilio.sendSMS({
        From: "+16178198676",
        To: request.params.number,
        Body: "Welcome to Pinsit!  Your verification code is " + request.params.verification
    }, {
        success: function(httpResponse) {
            response.success("SMS Sent");
        },
        error: function(httpResponse) {
            response.error("Something went wrong");
        }
    });
});
  
Parse.Cloud.define("setUserPhone", function(request, response) {
    var query = new Parse.Query(Parse.User);
    query.equalTo("objectId", request.params.userId);
    query.find({
        success: function(users) {
            Parse.Cloud.useMasterKey();
            users[0].set("phone", request.params.number);
            users[0].save();
            response.success();
        },
        error: function(error) {
            response.error(error.message);
        }
    })
});
  
Parse.Cloud.job("deleteOldPins", function(request, status) {
    var PinObject = Parse.Object.extend("SentData");
    var query = new Parse.Query(PinObject);
    var day = new Date();
  
    day.setDate(day.getDate() - 1);
    query.lessThan("createdAt", day);
  
    query.find({
        success: function(results) {
            Parse.Object.destroyAll(results);
            status.success("Successfully deleted " + results.length + " pins");
        }, error: function(error) {
            status.error("Something Went Wrong: " + error);
        }
    });
});