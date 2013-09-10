exports.subscribe = function(listId,email,gender,callback){
	var conf = require('cloud/conf.js');
	var keys = conf.keys;
	if(!email){
		if(callback) callback(false,'email required');
		return;
	}
	var mergeVars = false;
	if(gender) mergeVars = {"GENDER":gender};
	Parse.Cloud.httpRequest({
		url:'http://us7.api.mailchimp.com/1.3/',
		method:'POST',
		headers:{
			'Content-Type': 'application/json'
		},
		params:{
			method:'listSubscribe'
		},
		body:{
			merge_vars:mergeVars,
			apikey:keys.mailchimpToken,
			double_optin:false,
			id:listId,
			update_existing:true,
			email_address:email
		},
		success:function(result){
			if(callback) callback(result);
		},
		error:function(error){
			if(callback) callback(false,error);
		}
	});
};
exports.batchSubscribe = function(listId,emails,callback){
	var newEmails = [];
	for(var i = 0 ; i < emails.length ; i++){
		var email = emails[i];
		newEmails[i] = {"EMAIL":email,"EMAIL_TYPE":"html"};
	}
	var conf = require('cloud/conf.js');
	var keys = conf.keys;
	Parse.Cloud.httpRequest({
		url:'http://us7.api.mailchimp.com/1.3/',
		method:'POST',
		headers:{
			'Content-Type': 'application/json'
		},
		params:{
			method:'listBatchSubscribe'
		},
		body:{
			apikey:keys.mailchimpToken,
			id:listId,
			double_optin:false,
			batch:newEmails,
			update_existing:true
		},
		success:function(result){
			if(callback) callback(result);
		},
		error:function(error){
			if(callback) callback(false,error);
		}
	});
};
/*exports.update = function(email,gender,callback){
	var conf = require('cloud/conf.js');
	var keys = conf.keys;
	if(gender) var mergeVars = {"GENDER":gender};
	Parse.Cloud.httpRequest({
		url:'http://us7.api.mailchimp.com/1.3/',
		method:'POST',
		headers:{
			'Content-Type': 'application/json'
		},
		params:{
			method:'listUpdateMember'
		},
		body:{
			merge_vars:mergeVars,
			apikey:keys.mailchimpToken,
			id:keys.mailchimpList,
			email_address:email
		},
		success:function(result){
			if(callback) callback(result);
		},
		error:function(error){
			if(callback) callback(false,error);
		}
	});
};*/