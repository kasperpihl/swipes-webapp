
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.useMasterKey();
require('cloud/app.js');
Parse.Cloud.define("subscribe", function(request, response) {
  var email = request.params.email;
  if(!email) return response.error('Must include email');
  var Signup = Parse.Object.extend("Signup");
  var testQuery = new Parse.Query("Signup");
  testQuery.equalTo("email", email);
  testQuery.first({
    success: function(object) {
      if(object) return response.success('already');
      object = new Signup();
      object.set('email',email);
      object.save(null,{success:function(object){
        response.success('success');
      },error:function(object,error){
        response.error(error);
      }});
    },
    error: function() {
      response.error("movie lookup failed");
    }
  });
});
Parse.Cloud.define('batchUsers',function(request,response){
  var query = new Parse.Query(Parse.User);
  query.limit(1000);
  query.find({success:function(objects){
    if(objects && objects.length > 0){
      var emails = [];
      for(var i = 0 ; i < objects.length ; i++){
        var user = objects[i];
        emails[i] = user.get('username');
      }
      var conf = req('conf');
      var keys = conf.keys;
      var mailchimp = req('mailchimp');
      mailchimp.batchSubscribe(keys.userList,emails,function(result,error){
        if(error) response.error(error);
        else response.success(result);
      })
      
    }
  },error:function(error){
    response.error(error);
  }})

})
Parse.Cloud.beforeSave("Signup",function(request,response){
  var mailchimp = req('mailchimp');
  var conf = require('cloud/conf.js');
  var keys = conf.keys;
  mailchimp.subscribe(keys.subscribeList,request.object.get('email'),false,function(result,error){
    if(error) response.error(error);
    else response.success();
  });
});
Parse.Cloud.beforeSave(Parse.User,function(request,response){
  var object = request.object;
  if(object.dirty("username")){
    if(validateEmail(object.get('username'))){
      var conf = require('cloud/conf.js');
      var keys = conf.keys;
      var mandrill = req('mandrill');
      var mailchimp = req('mailchimp');
      mandrill.sendTemplate("welcome-email",object.get('username'),"Welcome on board!");
      mailchimp.subscribe(keys.userList,object.get('username'),object.get('gender'));
    }
  }
  response.success();
});
function req(module){
  return require('cloud/'+module+'.js');
}
function validateEmail(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}
function sendError(response,error){
  var user = Parse.User.current();
  var ServerError = Parse.Object.extend("ServerError");
  var serverError = new ServerError();
  console.error(error);
  serverError.set('user',user);
  serverError.set('error',error);
  serverError.save({
    success:function(){
      if(response) response.error(error);
    },error:function(error2){
      if(response) response.error(error);
    }
  });
}