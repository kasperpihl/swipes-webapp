// private property
var _keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
var eventName;
var distinct_id;
var properties;
exports.setAll = function(event,identifier,props){
	if(event) exports.setEvent(event);
	if(identifier) exports.setDistinctId(identifier);
	if(props) exports.setProperties(props);
};
exports.setEvent = function(event){
	eventName = event;
};
exports.setDistinctId = function(identifier){
	distinct_id = identifier;
};
exports.setProperties = function(object){
	properties = object;
};
exports.setProperty = function(key,value){
	properties[key] =  value;
};
exports.engage = function(user,callback){
	if(!user) return callback ? callback(null,'No user was given') : null;
	distinct_id = user.id;

	var conf = require('cloud/conf.js');
	var keys = conf.keys;
	var timeStamp = parseInt(new Date().getTime()/1000,10);

	var json = {
		"$set":{},
		"$token":keys.mixpanelToken,
		"$distinct_id":distinct_id
	};
	if(user.get('email')) json["$set"]["$email"] = user.get('email');
	if(user.get('first_name')) json["$set"]["$first_name"] = user.get('first_name');
	if(user.get('name')) json["$set"]["$last_name"] = user.get('name');
	exports.send('engage',json,callback);
};
exports.track = function(callback){
	if(!eventName) return callback ? callback(null,'No event has been set') : null;
	if(!distinct_id) return callback ? callback(null,'No distinct_id set') : null;

	var conf = require('cloud/conf.js');
	var keys = conf.keys;
	var timeStamp = parseInt(new Date().getTime()/1000,10);

	var json = {
		"event":eventName,
		"properties":{
			"token":keys.mixpanelToken,
			"time":timeStamp,
			"distinct_id":distinct_id
		}

	};
	if(properties){
		for(var key in properties){
			if(key == 'token') continue;
			var value = properties[key];
			json.properties[key] = value;
		}
		properties = null;
	}
	exports.send('track',json,callback);
};
exports.send = function (action,json,callback){
	var encodedData = exports.encode(JSON.stringify(json));
	var url = "http://api.mixpanel.com/"+action;
	Parse.Cloud.httpRequest({
		url:url,
		method:'GET',
		params:{
			data:encodedData
		},
		success:function(httpResponse){
			if(callback) callback(httpResponse.text);
		},
		error:function(error){
			if(callback) callback(null,error);
		}
	});
};
// public method for encoding
exports.encode = function (input) {
	var output = "";
	var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
	var i = 0;

	input = exports._utf8_encode(input);

	while (i < input.length) {

		chr1 = input.charCodeAt(i++);
		chr2 = input.charCodeAt(i++);
		chr3 = input.charCodeAt(i++);

		enc1 = chr1 >> 2;
		enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
		enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
		enc4 = chr3 & 63;

		if (isNaN(chr2)) {
			enc3 = enc4 = 64;
		} else if (isNaN(chr3)) {
			enc4 = 64;
		}

		output = output +
		_keyStr.charAt(enc1) + _keyStr.charAt(enc2) +
		_keyStr.charAt(enc3) + _keyStr.charAt(enc4);

	}

	return output;
};

// public method for decoding
exports.decode = function (input) {
	var output = "";
	var chr1, chr2, chr3;
	var enc1, enc2, enc3, enc4;
	var i = 0;

	input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

	while (i < input.length) {

		enc1 = _keyStr.indexOf(input.charAt(i++));
		enc2 = _keyStr.indexOf(input.charAt(i++));
		enc3 = _keyStr.indexOf(input.charAt(i++));
		enc4 = _keyStr.indexOf(input.charAt(i++));

		chr1 = (enc1 << 2) | (enc2 >> 4);
		chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
		chr3 = ((enc3 & 3) << 6) | enc4;

		output = output + String.fromCharCode(chr1);

		if (enc3 != 64) {
			output = output + String.fromCharCode(chr2);
		}
		if (enc4 != 64) {
			output = output + String.fromCharCode(chr3);
		}

	}

	output = exports._utf8_decode(output);

	return output;

};

// private method for UTF-8 encoding
exports._utf8_encode = function (string) {
	string = string.replace(/\r\n/g,"\n");
	var utftext = "";

	for (var n = 0; n < string.length; n++) {

		var c = string.charCodeAt(n);

		if (c < 128) {
			utftext += String.fromCharCode(c);
		}
		else if((c > 127) && (c < 2048)) {
			utftext += String.fromCharCode((c >> 6) | 192);
			utftext += String.fromCharCode((c & 63) | 128);
		}
		else {
			utftext += String.fromCharCode((c >> 12) | 224);
			utftext += String.fromCharCode(((c >> 6) & 63) | 128);
			utftext += String.fromCharCode((c & 63) | 128);
		}

	}

	return utftext;
};

// private method for UTF-8 decoding
exports._utf8_decode = function (utftext) {
	var string = "";
	var i = 0;
	var c = 0;
	var c1 = 0;
	var c2 = 0;

	while ( i < utftext.length ) {

		c = utftext.charCodeAt(i);

		if (c < 128) {
			string += String.fromCharCode(c);
			i++;
		}
		else if((c > 191) && (c < 224)) {
			c2 = utftext.charCodeAt(i+1);
			string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
			i += 2;
		}
		else {
			c2 = utftext.charCodeAt(i+1);
			c3 = utftext.charCodeAt(i+2);
			string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
			i += 3;
		}

	}

	return string;
};