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
		"click #oauth-button": "clickedOAuth"

	setBusyState: ->
		$("body").addClass "busy"
		@$el.find("input[type=submit]").val "please wait ..."
	removeBusyState: ->
		$("body").removeClass "busy"
		@$el.find("input[type=submit]").val "Signup"
	handleSubmitForm: (e) ->
		e.preventDefault()
		@doAction "slack", e
	clickedOAuth: ->
		@slackState = @generateId(10)
		window.open("https://slack.com/oauth/authorize?client_id=2345135970.9201204242&redirect_uri=http://team.swipesapp.com/slacksuccess/&scope=client&state="+@slackState,"Authorize Swipes w/ Slack", "height=500,width=500")
		return
	doAction: (action, e) ->
		if $("body").hasClass "busy" then return console.warn "Can't do #{action} right now — I'm busy ..."
		@setBusyState()
		switch action
			when "slack"
				token = @$el.find("#slack-token").val()
				if e.currentTarget.id is "slack-bottom-form"
					token = @$el.find("#slack-token-bottom").val()
				options = {token: token}
				$.ajax( {
					url: "https://slack.com/api/auth.test"
					type:"POST"
					success: (data) =>
						@removeBusyState()
						if data and data.ok
							@handleUserLoginSuccess(token)
						else
							alert(JSON.stringify(data))
					error: (error) =>
						@removeBusyState()
						alert(JSON.stringify(error))
					crossDomain: true
					context: @
					data: options
					processData: true
				})
	handleSlackSuccess:(code, state, QueryString) ->
		self = @
		@setBusyState()
		console.log @slackState, state, QueryString
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
			
	handleUserLoginSuccess: (token) ->
		localStorage.setItem("slack-token", token )
		pathName = location.origin

		if(queryString && queryString.href)
			pathName += "?href=" + queryString.href
		if(location.hash)
			pathName += location.hash
		
		location.href = pathName
		return
	showError: (error) ->
		alert "something went wrong. Please try again."

queryString = QueryString()

# Finally, instantiate a new SwipesLogin

login = new LoginView()
window.loginView = login