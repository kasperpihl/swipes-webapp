// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.useMasterKey();
require('cloud/app.js');
Parse.Cloud.beforeSave("ToDo",function(request,response){
  var user = request.user;
  if(!user && !request.master) return sendError(response,'You have to be logged in to save ToDo');
  if(!request.master && request.object.dirty('owner')) return sendError(response,"Not allowed to change owner");
  var attrWhitelist = ["title","order","schedule","completionDate","repeatOption","repeatDate","repeatCount","tags","notes","location","priority"];
  handleObject(request.object, attrWhitelist);
  response.success();
});
function handleObject(object,attrWhiteList){
  var _ = require('underscore');
  var defAttributes = ["deleted","attributeChanges","tempId","owner"];
  if(attrWhiteList){
    for(var attribute in object.attributes){
      if(_.indexOf(attrWhiteList,attribute) == -1 && _.indexOf(defAttributes,attribute) == -1) delete object.attributes[attribute];
    }
  }
  makeAttributeChanges(object);
  var user = Parse.User.current();
  if(!user) user = object.get('owner');
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
      if(attribute == "deleted" || attribute == "tempId") continue;
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
Parse.Cloud.define('cleanup',function(request,response){
  var query = new Parse.Query('ServerError');
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

function queriesForUpdating(user,lastUpdate,nowTime,options){
  if(!user) return false;

  var tagQuery = new Parse.Query('Tag');
  tagQuery.equalTo('owner',user);
  if(lastUpdate) tagQuery.greaterThanOrEqualTo('updatedAt',lastUpdate);
  else tagQuery.notEqualTo('deleted',true);
  if(nowTime) tagQuery.lessThanOrEqualTo('updatedAt',nowTime);

  var taskQuery = new Parse.Query('ToDo');
  taskQuery.equalTo('owner',user);
  if(lastUpdate) taskQuery.greaterThanOrEqualTo('updatedAt',lastUpdate);
  else taskQuery.notEqualTo('deleted',true);
  if(nowTime) taskQuery.lessThanOrEqualTo('updatedAt',nowTime);
  return [tagQuery,taskQuery];
};
/* Running a query unlimited with skips if limit of object is reached
  callback (result,error)
*/
function runQueryToTheEnd(query,callback,deltaResult,deltaSkip){
  if(!deltaResult) deltaResult = [];
  if(deltaSkip) query.skip(parseInt(deltaSkip,10));
  query.limit(1000);
  query.find({success:function(result){
    var runAgain = false;
    if(result && result.length > 0){ 
      deltaResult = deltaResult.concat(result);
      if(result.length == 1000) runAgain = true;
    }
    if(runAgain) runQueryToTheEnd(query,callback,deltaResult,(deltaSkip+1000));
    else callback(deltaResult,false);
  },error:function(error){
    callback(deltaResult,error);
  }});
};
Parse.Cloud.define('sync',function(request,response){
  var user = Parse.User.current();
  if(!user) return sendError(response,'You have to be logged in');
  var startTime = new Date();
  var tagObjects = makeParseObjectsFromRaw(request.params.objects["Tag"],"Tag",user);
  var todoObjects = makeParseObjectsFromRaw(request.params.objects["ToDo"],"ToDo",user);
  var batches = makeBatchesFromParseObjects(todoObjects,tagObjects);
  var lastUpdate = (request.params.lastUpdate) ? new Date(request.params.lastUpdate) : false;
  
  function saveAll(){
    var queue = require('cloud/queue.js');
    queue.push(batches,true);
    var saveError;
    queue.run(function(batch){
      Parse.Object.saveAll(batch,{success:function(result){
        queue.next();
      },error:function(result,error){
        // TODO: Handle error on batches here
        queue.next();
      }});
    },function(finished){
      if(saveError) return response.error(saveError);
      else fetchAll();
    });
  };
  
  function fetchAll(){
    var queue = require('cloud/queue.js');
    queue.reset();
    var resultObjects = {};
    var queryError;
    var updateTime = new Date();
    var queries = queriesForUpdating(user,lastUpdate,updateTime);
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
  };
  if(batches && batches.length > 0) saveAll();
  else fetchAll();

  
    
    
    
  
});
function makeBatchesFromParseObjects(todoObjects,tagObjects){
  var batches = new Array();
  if(!todoObjects && !tagObjects) return batches;
  var noRelation = new Array();
  var dependency = new Array();
  var tagIdentifiers = new Array();
  var chunkSize = 50;

  var _ = require("underscore");
  /* Preparing todo's - checking for relation dependencies */
  for(var identifier in todoObjects){
    var todo = todoObjects[identifier];
    /* Checking tags */
    var tags = todo.get('tags');
    if(!tags){
      noRelation.push(todo); 
    }
    else{
      var dependent = false;
      var Tag = Parse.Object.extend("Tag");
      var tagObjects = new Array();
      var dependent = false;
      for(var i = 0 ; i < tags.length ; i++){
        var rawTag = tags[i];
        var tagObj;
        if(rawTag.objectId){
          tagObj = new Tag({"objectId":rawTag.objectId});
        }
        else if(rawTag.tempId){ 
          tagObj = todoObjects[rawTag.tempId];
          if(tagObj){ 
            tagIdentifiers.push(rawTag.tempId);
            dependent = true;
          }
        }        
        if(tagObj) tagObjects.push(tagObj);
      }
      todo.set("tags",tagObjects);
      if(dependent) dependency.push(todo);
      else noRelation.push(todo);
    }
  }
  var testTags = false;
  if(tagIdentifiers.length > 0){
    _.uniq(tagIdentifiers);
    testTags = true;
  }
  for(var identifier in tagObjects){
    var dependend = false;
    var tag = tagObjects[identifier];
    if(testTags && _.indexOf(tagIdentifiers,identifier) != -1) dependent = true;
    if(dependent) dependency.push(tag);
    else noRelation.push(tag);
  }
  
  if(noRelation.length > 0){
    for (i = 0, j = noRelation.length; i < j; i += chunkSize) {
      batches.push(noRelation.slice(i, i + chunkSize));
    }
  }

  if(dependency.length > 0){
    var lastBatch = batches[batches.length];
    if((lastBatch.length + dependency) <= 50) lastBatch = lastBatch.concat(dependency);
    else batches.push(dependency);
  }
  return batches;
};
function makeParseObjectsFromRaw(objects,className,user){
  if(!objects || objects.length == 0) return false;
  var ParseObject = Parse.Object.extend(className);
  var collection = {};
  for(var i = 0 ; i < objects.length ; i++){
    var rawObject = objects[i];
    var parseObject = new ParseObject(rawObject);
    if(parseObject.id){
      collection[parseObject.id] = parseObject;
    }
    else if(parseObject.get('tempId')){
      collection[parseObject.get('tempId')] = parseObject;
      parseObject.set('owner',user);
    }
  }
  return collection;
}
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
  if(object.dirty('userLevel') && !request.master){
    return sendError(response,'User not allowed to change this');
  }
  if(object.dirty("username")){
    if(validateEmail(object.get('username'))){
      var conf = require('cloud/conf.js');
      var keys = conf.keys;
      var mailjet = req('mailjet');
      mailjet.request("listsAddcontact",{"id":"370097","contact":object.get('username')});
      mandrill.sendTemplate("welcome-again",object.get('username'),"Welcome news & tips",function(result,error){
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
  var queries = queriesForUpdating(user,lastUpdate,updateTime);
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