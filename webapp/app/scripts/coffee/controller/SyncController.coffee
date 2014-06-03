###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "backbone", "jquery"], (_, Backbone, $) ->
	class SyncController
		constructor: ->

			@lastUpdate = null
			@sync()
		saveToSync: (objects) ->
			@handleModelForSync object for object in objects
		handleModelForSync: (model) ->
			console.log model
		prepareObjects: ->
			console.log "prepare"


		sync: ->
			url = "http://localhost:5000/v1/sync"
			user = Parse.User.current()
			token = user.getSessionToken()

			data =
				sessionToken : token
			serData = JSON.stringify data

			settings = 
				url : url
				type : 'POST'
				success : @responseFromSync
				error : @errorFromSync
				dataType : "json"
				contentType: "application/json; charset=utf-8"
				crossDomain : true
				data : serData
				processData : false
			
			$.ajax( settings ) 
			@prepareObjects() if @lastUpdate?

		errorFromSync: ( data, textStatus, error ) ->

		responseFromSync: ( data, textStatus ) ->
			##console.log 'response'
			if data and data.serverTime
				console.log data.Tag
			console.log data