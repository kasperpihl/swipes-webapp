exports.keys = {
	mailchimpToken:"ecf74584af1de945beeb71c8918ed5a7-us7",
	mandrillToken:"57qNzppc1FU7BdYnuF6GXw",
	subscribeList:"c08c034fd4",
	userList:"cfd40b73c7",

	mailjetAPIToken:"0b7060208dd74c1f9f48aa22f223a558",
	mailjetSecretToken:"e844af6cac6dd42a0b9a732905e1936f",
	mailjetUserListId:370097
};
exports.get = function(keys,callback){
	var query = new Parse.Query('Configuration');
	query.containedIn('key',keys);
	query.find({
		success:function(objects){
			var configurations = {};
			for(var i = 0 ; i < objects.length ; i++){
				var o = objects[i];
				configurations[o.get('key')] = o.get('value');
			}
			callback(configurations);
		},
		error:function(error){
			callback(null,error);
		}
	});
};
exports.get = function(keys,callback){
	var query = new Parse.Query('Configuration');
	query.containedIn('key',keys);
	query.find({
		success:function(objects){
			var configurations = {};
			for(var i = 0 ; i < objects.length ; i++){
				var o = objects[i];
				configurations[o.get('key')] = o.get('value');
			}
			callback(configurations);
		},
		error:function(error){
			callback(null,error);
		}
	});
};