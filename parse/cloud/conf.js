exports.keys = {
	mixpanelToken:"c2d2126bfce5e54436fa131cfe6085ad",
	mailchimpToken:"ecf74584af1de945beeb71c8918ed5a7-us7",
	mandrillToken:"57qNzppc1FU7BdYnuF6GXw",
	subscribeList:"c08c034fd4",
	userList:"cfd40b73c7"
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