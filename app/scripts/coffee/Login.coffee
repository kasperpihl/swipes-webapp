### Analytics Controller ###

isInt = (n) ->
		typeof n is 'number' and n % 1 is 0
QueryString = =>
	query_string = {}
	query = window.location.search.substring(1)
	vars = query.split("&")
	for attSet in vars
		pair = attSet.split("=")
		if typeof query_string[pair[0]] is "undefined"
			query_string[pair[0]] = pair[1]
		else if typeof query_string[pair[0]] is "string"
			arr = [ query_string[pair[0]], pair[1] ]
			query_string[pair[0]] = arr
		else
			query_string[pair[0]].push(pair[1])
	query_string
LoginView = Backbone.View.extend
	el: "#login"
	generateId: ( length ) ->
		text = ""
		possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

		for i in [0..length]
			text += possible.charAt(Math.floor(Math.random() * possible.length))
		return text
	events:
		"click input[type=submit]": "clickedOAuth"

	setBusyState: ->
		$("body").addClass "busy"
		@$el.find("input[type=submit]").val "please wait ..."
	removeBusyState: ->
		$("body").removeClass "busy"
		@$el.find("input[type=submit]").val "LOGIN WITH SLACK"
	handleSubmitForm: (e) ->
		e.preventDefault()
		@doAction "slack", e
	clickedOAuth: ->

		@slackState = @generateId(10)
		amplitude.logEvent "[Login] Clicked Login Button"
		window.open("https://slack.com/oauth/authorize?client_id=2345135970.9201204242&redirect_uri=http://team.swipesapp.com/slacksuccess/&scope=client&state="+@slackState,"Authorize Swipes w/ Slack", "height=700,width=500")
		
		return
	handleSlackSuccess:(code, state, QueryString) ->
		self = @
		@setBusyState()
		amplitude.logEvent "[Login] Successfully Logged In"
		if state is @slackState
			console.log code, state
			serverData = JSON.stringify {code: code}
			settings = 
				url : "http://swipesslack.elasticbeanstalk.com/v1/slackToken"
				type : 'POST'
				success : ( data ) ->
					self.removeBusyState()
					if data and data.ok
						localStorage.setItem("slack-token", data.access_token)
						pathName = location.origin

						if(queryString && queryString.href)
							pathName += "?href=" + queryString.href
						if(location.hash)
							pathName += location.hash
						
						location.href = pathName
					else
						console.log data
						alert("An error occured logging in to Slack")
				error : ( error ) ->
					self.removeBusyState()
					console.log error
					alert("An error occured logging in to Slack")
				dataType : "json"
				contentType: "application/json; charset=utf-8"
				crossDomain : true
				context: @
				data : serverData
				processData : false
			#console.log serData
			$.ajax( settings )
amplitude.logEvent "[Login] Opened Login"
queryString = QueryString()
if queryString.token
	localStorage.setItem("slack-token", queryString.token)
	pathName = location.origin

	if(queryString && queryString.href)
		pathName += "?href=" + queryString.href
	if(location.hash)
		pathName += location.hash
	
	location.href = pathName

# Finally, instantiate a new SwipesLogin

login = new LoginView()
window.loginView = login
if window.process? and process.versions['electron']
	require('ipc').on('slack_login', (event, QueryString) ->
		loginView.handleSlackSuccess(QueryString.code, QueryString.state, QueryString)
	)