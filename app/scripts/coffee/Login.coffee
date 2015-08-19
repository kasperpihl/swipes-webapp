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

LoginView = Parse.View.extend
	el: "#login"
	events:
		"submit form": "handleSubmitForm"
	setBusyState: ->
		$("body").addClass "busy"
		@$el.find("input[type=submit]").val "please wait ..."
	removeBusyState: ->
		$("body").removeClass "busy"
		@$el.find("input[type=submit]").val "Continue"
	handleSubmitForm: (e) ->
		e.preventDefault()
		@doAction "slack"
	doAction: (action) ->
		if $("body").hasClass "busy" then return console.warn "Can't do #{action} right now — I'm busy ..."
		@setBusyState()
		switch action
			when "slack"
				token = @$el.find("#slack-token").val()
				options = {token: token}
				console.log token
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
		switch error.code
			when Parse.Error.USERNAME_TAKEN, Parse.Error.EMAIL_NOT_FOUND then alert "The password was wrong"
			when Parse.Error.INVALID_EMAIL_ADDRESS then alert "The provided email is invalid. Please check it, and try again"
			when Parse.Error.TIMEOUT then alert "The connection timed out. Please try again."
			when Parse.Error.USERNAME_TAKEN then alert "The email/username was already taken"
			when 202 then alert "The email is already in use, please login instead"
			when 101 then alert "Wrong email or password"
			else alert "something went wrong. Please try again."

queryString = QueryString()

# Finally, instantiate a new SwipesLogin
login = new LoginView()