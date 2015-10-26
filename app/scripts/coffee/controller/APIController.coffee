###

###

define ["underscore", "jquery", "js/utility/Utility"], (_, $, Utility) ->
	class APIController

		constructor: ->
			@util = new Utility()
			@baseURL = "http://swipesslack.elasticbeanstalk.com/v1/"
		callAPI: (path, method, parameters, callback) ->
			url = @baseURL + path
			token = localStorage.getItem("slack-token")
			data =
				sessionToken : token
				platform : "web"
				version: 1

			for key, value of parameters
				data[key] = value
			console.log data

			serverData = JSON.stringify data

			settings =
				url : url
				type : 'POST'
				success : ( data ) ->
					if data and data.ok
						callback(data);
					else
						callback(false, data);
				error : ( error ) ->
					#@util.sendError( error, "Server Error")
					callback(false, error)
				dataType : "json"
				contentType: "application/json; charset=utf-8"
				xhrFields:
					withCredentials: true
				crossDomain : true
				context: @
				data : serverData
				processData : true
			#console.log serData
			$.ajax( settings )
