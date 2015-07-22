Parse.Cloud.define("verifyNumber", function(request, response) {
    var twilio = require("twilio")("AC90b7d2008703ddfb9c8acc3274c1d924", "9968159162bcf90e1c63c2860c0a0847");
   
    twilio.sendSms({
        to: request.params.number,
		from: "+17814793999",
        body: "Welcome to Pinsit!  Your verification code is " + request.params.verification
    }, function (err, responseData) {
		if (err) {
			response.error(err)
		} else {
			response.success();
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