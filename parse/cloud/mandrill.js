exports.sendTemplate = function(templateName,email,subject,callback){
	var conf = require('cloud/conf.js');
	var keys = conf.keys;
	if(!email){
		if(callback) callback(false,'email required');
		return;
	}
	var body = {
		"key":keys.mandrillToken,
		"template_name":templateName,
		"template_content": [],
		"message":{
			"subject":subject,
			"from_email":"support@swipesapp.com",
			"from_name":"The Swipes Team",
			"to":[{
				"email":email
			}],
			"important": false,
			"track_opens": true,
			"track_clicks": true,
			"auto_text": null,
			"auto_html": null,
			"inline_css": null,
			"url_strip_qs": null,
			"preserve_recipients": null,
			"tracking_domain": null,
			"signing_domain": null,
			"merge": true
		},
		"async":true
	};
	Parse.Cloud.httpRequest({
		url:'https://mandrillapp.com/api/1.0/messages/send-template.json',
		method:'POST',
		headers:{
			'Content-Type': 'application/json'
		},
		params:{
		},
		body:body,
		success:function(result){
			if(callback) callback(result);
		},
		error:function(error){
			if(callback) callback(false,error);
		}
	});
};