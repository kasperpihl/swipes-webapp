// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.useMasterKey();
Parse.Cloud.beforeSave("ToDo",function(request,response){
  var user = request.user;
  if(!user && !request.master) return sendError(response,'You have to be logged in to save ToDo');
  if(!request.master && request.object.dirty('owner')) return sendError(response,"Not allowed to change owner");
  if(request.object.get('owner') && request.object.get('lastSave')){
    if(request.object.get('owner').id != request.object.get('lastSave').id) return sendError(response,'Unauthorized Save'); 
  }
  var attrWhitelist = ["title","order","schedule","completionDate","repeatOption","repeatDate","repeatCount","tags","notes","location","priority"];
  handleObject(request.object, attrWhitelist);
  response.success();
});
function handleObject(object,attrWhiteList){
  var _ = require('underscore');
  var defAttributes = ["deleted","attributeChanges","tempId","owner","lastSave"];
  if(attrWhiteList){
    for(var attribute in object.attributes){
      if(_.indexOf(attrWhiteList,attribute) == -1 && _.indexOf(defAttributes,attribute) == -1) delete object.attributes[attribute];
    }
  }
  makeAttributeChanges(object);
  var user = Parse.User.current();
  if(!user) user = object.get('lastSave');
  if(object.isNew() && user){ 
    object.set('owner',user);
    var ACL = new Parse.ACL();
    ACL.setReadAccess(user.id,true);
    ACL.setWriteAccess(user.id,true);
    object.setACL(ACL);
  }
}
function makeAttributeChanges(object){
  var attributes = object.attributes;
  var updateTime = new Date();
  var changes = object.get('attributeChanges');
  if(!changes) changes = {};
  if(attributes){
    var hasChanged = false;
    for(var attribute in attributes){
      if(object.dirty(attribute) && attribute != 'attributeChanges'){ 
        hasChanged = true;
        changes[attribute] = updateTime;
      }
    }
    if(hasChanged) object.set('attributeChanges',changes);
  }
}
function scrapeChanges(object,lastUpdateTime){
  var attributes = object.attributes;
  var updateTime = new Date();
  if(!attributes['attributeChanges']) return;
  if(!lastUpdateTime) return delete attributes['attributeChanges'];
  var changes = object.get('attributeChanges');
  if(!changes) changes = {};
  if(attributes){
    for(var attribute in attributes){
      var lastChange = changes[attribute];
      if((attribute == "deleted" && attributes[attribute]) || attribute == "tempId") continue;
      if(!lastChange || lastChange <= lastUpdateTime) delete attributes[attribute];
    }
  }
}

Parse.Cloud.beforeSave('Payment',function(request,response){
  var user = request.user;
  if(!user && !request.master) return sendError(response,'You have to be logged in to save Payment');
  var payment = request.object;
  payment.set('user',user);
  var productIdentifier = payment.get('productIdentifier');
  var callback = {
    success: function(savedUser) {
      response.success();
    },
  	error: function(savedUser, error) {
      console.error("Error upgrading user: "+ savedUser.id);
      console.error(error);
      response.success();
    }
  };
  if(productIdentifier == 'plusMonthlyTier1'){
    user.set('userLevel',2);
    user.save(null,callback);
  }
  else if(productIdentifier == 'plusYearlyTier10'){
    user.set('userLevel',3);
    user.save(null,callback);
  }
});
Parse.Cloud.beforeSave("Tag",function(request,response){
  var user = request.user;
  if(!user && !request.master) return sendError(response,'You have to be logged in to save Tag');
  if(!request.master && request.object.dirty('owner')) return sendError(response,"Not allowed to change owner");
  if(request.object.get('owner') && request.object.get('lastSave')){
    if(request.object.get('owner').id != request.object.get('lastSave').id) return sendError(response,'Unauthorized Save'); 
  }
  var attrWhitelist = ["title"];
  handleObject(request.object);
  response.success();
});

Parse.Cloud.define('checkEmail',function(request,response){
  var email = request.params.email;
  if(!email) return sendError(response,'You need to include email');
  var query = new Parse.Query(Parse.User);
  query.equalTo('username',email);
  query.count({success:function(counter){
    if(counter > 0) response.success(1);
    else response.success(0);
  },error:function(error){ sendError(response,error); }});
});
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

/* Running a query unlimited with skips if limit of object is reached
  callback (result,error)
*/
function runQueryToTheEnd(query,callback,deltaResult,deltaSkip){
  if(!deltaResult) deltaResult = [];
  if(!deltaSkip) deltaSkip = 0;
  if(deltaSkip) query.skip(parseInt(deltaSkip,10));
  query.limit(1000);
  query.find({success:function(result){
    var runAgain = false;
    if(result && result.length > 0){
      deltaResult = deltaResult.concat(result);
      if(result.length == 1000) runAgain = true;
    }
    if(runAgain){ 
      deltaSkip = deltaSkip + 1000;
      runQueryToTheEnd(query,callback,deltaResult,deltaSkip);
    }
    else callback(deltaResult,false,query);
  },error:function(error){
    callback(deltaResult,error,query);
  }});
};
Parse.Cloud.define("unsubscribe",function(request,response){
  var email = request.params.email;
  if(!email) return response.error('Must include email');
  var mailjet = req('mailjet');
  mailjet.request("listsUnsubcontact",{"id":"370097","contact":email},function(result,error){
    if(error) response.error(error);
    else response.success(result);
  });
});
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
  var mandrill = req('mandrill');
  var vero = req('vero');
  if(object.dirty('userLevel') && !request.master){
    return sendError(response,'User not allowed to change this');
  }
  if(object.dirty("username")){
    if(validateEmail(object.get('username'))){
      var conf = require('cloud/conf.js');
      var keys = conf.keys;
      var mailjet = req('mailjet');
      mailjet.request("listsAddcontact",{"id":"370097","contact":object.get('username')});
      vero.track('Signs up',{user:object},function(result,error){
        response.success();
      });
    } else response.success();
  }
  else if(object.dirty('userLevel') && object.get('userLevel') > 0){
    var email = false;
    if(validateEmail(object.get('username'))) email = object.get('username');
    else if(validateEmail(object.get('email'))) email = object.get('email');
    mandrill.sendTemplate('email-to-plus',email,"Welcome to Swipes Plus",function(result,error){
      if(result) response.success();
      else if(error == 'email required') response.success();
      else response.error(error);
    });
  }
  else response.success();
});

Parse.Cloud.define('test',function(request,response){
  var vero = req('vero');
  var object = Parse.User.current();
  vero.track('Signs up',{user:object},function(result,error){
    if(error)
      response.error(error);
    else 
      response.success("success");
  });
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

Parse.Cloud.job("trialRevoke", function(request, status) {
  // Set up to modify user data
  Parse.Cloud.useMasterKey();
  var counter = 0;
  // Query for all users
  var now = new Date();
  var query = new Parse.Query("Trial");
  query.include('user');
  query.notEqualTo('revoked',true);
  query.lessThan('endDate',now);
  query.each(function(trial){
    var user = trial.get('user');
    user.set('userLevel',0);
    trial.set('revoked',true);
    trial.save();
    counter++;
    return user.save();
  }).then(function() {
    // Set the job's success status
    status.success("Migration completed " + counter + " successfully.");
  }, function(error) {
    // Set the job's error status
    status.error("Uh oh, something went wrong.");
  });
});


Parse.Cloud.define('update',function(request,response){
  var user = Parse.User.current();
  var updateTime = new Date(new Date().getTime());
  if(!user) return sendError(response,'You have to be logged in');

  var limit = 1000;
  var skip = request.params.skip;
  var lastUpdate = false;
  if(request.params.lastUpdate) lastUpdate = new Date(request.params.lastUpdate);
  var changesOnly = request.params.changesOnly ? lastUpdate : false;

  var queue = require('cloud/queue.js');

  var resultObjects = {};
  var queryError;
  var updateTime = new Date();

  var queryUtility = req('queryUtility');
  var queries = queryUtility.queriesForUpdating(user,lastUpdate,updateTime);
  queue.push(queries,true);
  queue.run(function(query){
    runQueryToTheEnd(query,function(result,error){
      if(!error && result && result.length > 0){
        for(var i = 0 ; i < result.length ; i++)
          scrapeChanges(result[i],lastUpdate);
        var index = result[0].className;
        resultObjects[index] = result;
        queue.next();
      }
      else{
        if(error) queryError = error;
        queue.next();
      }
    });
  },function(finished){
    if(queryError) return response.error(queryError);
    resultObjects.updateTime = updateTime.toISOString();
    resultObjects.serverTime = new Date().toISOString();
    response.success(resultObjects);
  });
});