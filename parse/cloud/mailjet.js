var _apiKey;
var _secretToken;
exports.initialize = function(apiKey,secretToken){
	_apiKey = apiKey;
	_secretToken = secretToken;
}
exports.request = function(method,parameters,callback,request){
	if(!request) request = "POST";
	var conf = require('cloud/conf.js');
	var keys = conf.keys;
	var encoder = require('cloud/encode.js');
	var auth = "Basic "+ encoder.encode(keys.mailjetAPIToken+":"+keys.mailjetSecretToken);
	var body;
	var params;
	var url = "https://api.mailjet.com/0.1/" + method;
	if(request == "POST"){
		if(parameters) body = parameters;
	}
	else {
		if(parameters) params = parameters;
	}
	if(params) params["output"] = "json";
	Parse.Cloud.httpRequest({
		url:url,
		method:request,
		headers:{
			"Authorization": auth
		},
		params:params,
		body:body,
		success:function(result){
			if(callback) callback(result);
		},
		error:function(error){
			if(callback) callback(false,error);
		}
	});
};