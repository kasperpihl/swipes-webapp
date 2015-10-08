###

###

define ["underscore", "jquery", "js/utility/Utility"], (_, $, Utility) ->
	class APIController

		constructor: ->
			@util = new Utility()
			@baseURL = "http://localhost:5000/v1/"
			#@baseURL = "http://swipesslack.elasticbeanstalk.com/v1/"
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
				type : method
				success : ( res ) ->
					if res
						callback(res);
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
