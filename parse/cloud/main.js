// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.useMasterKey();
require('cloud/app.js');
Parse.Cloud.beforeSave("ToDo",function(request,response){
  var user = request.user;
  if(!user && !request.master) return sendError(response,'You have to be logged in');
  var todo = request.object;
  var attrWhitelist = [ "title","order","schedule","completionDate","repeatOption","repeatDate","repeatCount","tags","notes","location","priority","owner","deleted","attributeChanges"];
  var _ = require('underscore.js');
  for(var attribute in todo.attributes){
    if(_.indexOf(attrWhitelist,attribute) == -1) delete todo.attributes[attribute];
  }
  makeAttributeChanges(todo);
  if(todo.isNew() && user) todo.set('owner',user);
  response.success();
});
Parse.Cloud.beforeSave("Tag",function(request,response){
  var user = request.user;
  if(!user && !request.master) return sendError(response,'You have to be logged in');
  var tag = request.object;
  var attrWhitelist = ["deleted", "owner", "title", "attributeChanges"];
  var _ = require('underscore.js');
  for(var attribute in tag.attributes){
    if(_.indexOf(attrWhitelist,attribute) == -1){ 
      tag.unset(attribute);
      delete tag.attributes[attribute];
    }
  }
  makeAttributeChanges(tag);
  if(tag.isNew() && user) tag.set('owner',user);
  response.success();
});
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
      if(!lastChange || lastChange <= lastUpdateTime) delete attributes[attribute];
    }
  }
}
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
Parse.Cloud.define('cleanup',function(request,response){
  var query = new Parse.Query('Tag');
  query.limit(1000);
  query.find({success:function(objects){ 
    Parse.Object.destroyAll(objects,{
      success:function(){
        response.success(); 
      },error:function(error){ 
        response.error(error); 
      }});},error:function(error){
      response.error(error);
      }
    });
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
Parse.Cloud.define('update',function(request,response){
  var user = Parse.User.current();
  var updateTime = new Date(new Date().getTime());
  if(!user) return sendError(response,'You have to be logged in');
  

  var skip = request.params.skip;
  var lastUpdate = false;
  if(request.params.lastUpdate) lastUpdate = new Date(request.params.lastUpdate);
  var changesOnly = request.params.changesOnly ? lastUpdate : false;

  var queue = require('cloud/queue.js');
  var tagQuery = new Parse.Query('Tag');
  tagQuery.equalTo('owner',user);
  tagQuery.limit(1000);
  if(skip) tagQuery.skip(skip);
  if(lastUpdate) tagQuery.greaterThan('updatedAt',lastUpdate);
  queue.addToQueue(tagQuery);

  var taskQuery = new Parse.Query('ToDo');
  taskQuery.equalTo('owner',user);
  taskQuery.limit(1000);
  if(skip) taskQuery.skip(skip);
  if(lastUpdate) taskQuery.greaterThan('updatedAt',lastUpdate);
  queue.addToQueue(taskQuery);

  runQueue(queue.getQueue(),function(objects,error){
    if(error) sendError(response,error);
    else{
      objects.updateTime = updateTime.toISOString();
      response.success(objects);
      
    }
  },{recurring:3,changesSince:changesOnly});
});
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
  if(object.dirty("username")){
    if(validateEmail(object.get('username'))){
      var conf = require('cloud/conf.js');
      var keys = conf.keys;
      var mandrill = req('mandrill');
      var mailjet = req('mailjet');
      mailjet.request("listsAddcontact",{"id":"370097","contact":object.get('username')});
      mandrill.sendTemplate("welcome-email-new",object.get('username'),"Welcome to Swipes!");
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
function runQueue(queue,done,options){
  function performQuery(object,callback){
    var query = object.query;
    var optionObject = {
      success:function(result){
        callback(object,result);
      },
      error:function(error){
        callback(object,null,error);
      }
    };
    if(object.count) query.count(optionObject);
    else query.find(optionObject);
  }
  var recurring = 1;
  if(options && options.recurring) recurring = options.recurring;
  var k = 0;
  var doneCounter = 0;
  var calledDone= false;
  var target = queue.length;
  if(target === 0) return done(false,null);
  var returnObj = {};
  function checkDone(){
    if(calledDone) return;
    if(doneCounter == target){
      done(returnObj,null);
      calledDone = true;
    }
    else next();
  }
  function next(){
    if(k>=target){
      return;
    }
    performQuery(queue[k],function(object,result,error){
      if(error && !calledDone){
        done(null,error);
        calledDone = true;
      }
      else{
        if(result.length > 0){
          for(var i = 0 ; i < result.length ; i++){
            var obj = result[i];
            scrapeChanges(obj,options.changesSince);
          }
        }
        returnObj[object.title] = result;
        doneCounter++;
        checkDone();
      }
      
    });
    k++;
  }
  for(var i = 0 ; i < recurring ; i++){
    next();
  }
}
