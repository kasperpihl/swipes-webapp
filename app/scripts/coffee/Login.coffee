LoginView = Parse.View.extend
	el: "#login"
	events:
		"submit form": "handleSubmitForm"
		"click #facebook-login": "facebookLogin"
		"click .reset-password": "resetPassword"
	facebookLogin: (e) -> @doAction "facebookLogin"
	setBusyState: ->
		$("body").addClass "busy"
		@$el.find("input[type=submit]").val "please wait ..."
	removeBusyState: ->
		$("body").removeClass "busy"
		@$el.find("input[type=submit]").val "Continue"
	handleSubmitForm: (e) ->
		e.preventDefault()
		@doAction "login"
	doAction: (action) ->
		if $("body").hasClass "busy" then return console.warn "Can't do #{action} right now — I'm busy ..."
		@setBusyState()

		switch action
			when "login"
				email = @$el.find( "#email" ).val()
				password = @$el.find( "#password" ).val()
				return @removeBusyState() unless @validateFields( email, password )

				Parse.User.logIn( email, password, {
					success: -> location.pathname = "/"
					error: (user, error) => @handleError( user, error, { email, password } )
				})
			when "register"
				console.log "Registering a new user"
				email = @$el.find( "#email" ).val()
				password = @$el.find( "#password" ).val()
				return @removeBusyState() unless @validateFields( email, password )

				@createUser( email, password ).signUp()
				.done( -> location.pathname = "/" )
				.fail (user, error) => @handleError( user, error )
			when "facebookLogin"
				Parse.FacebookUtils.logIn( null, {
					success: @handleFacebookLoginSuccess
					error: (user, error) => @handleError( user, error )
				})
	handleFacebookLoginSuccess: (user) ->
		if not user.existed
			signup = yes # Will be true if it was a signup
		unless user.get "email" then FB.api "/me", (response) ->
			if response.gender
				user.set( "gender", response.gender )
			if response.email
				user.set( "email", response.email )
				user.set( "username", response.email )
				user.save()
			location.href = "/"
		else
			location.href = "/"
	resetPassword: ->
		email = prompt "Which email did you register with?"
		if email then Parse.User.requestPasswordReset( email, {
			success: -> alert "An email was sent to '#{email}' with instructions on resetting your password"
			error: (error) -> alert "Error: #{ error.message }"
		})
	createUser: (email, password) ->
		user = new Parse.User()
		user.set( "username", email )
		user.set( "password", password )
		user.set( "email", email )
		return user
	validateFields: (email, password) ->
		if not email
			alert "Please fill in yourF e-mail address"
			return no

		if not password
			alert "Please fill in your password"
			return no

		if email.length is 0 or password.length is 0
			alert "Please fill out both fields"
			return no
		if not @validateEmail email
			alert "Please use a real email address"
			return no
		# Everything passed
		return yes
	validateEmail: (email) ->
		regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
		return regex.test email
	handleError: (user, error, triedLoginWithCredentials = no) ->
		if triedLoginWithCredentials
			# Figure out if the error was that the user didn't exist. If true, do the login.
			if error and error.code then switch error.code
				when 101
					if confirm "You're about to create a new user with the e-mail #{ triedLoginWithCredentials.email }. Do you want to continue?"
						@removeBusyState()
						return @doAction "register"
					else
						return
				else return @showError error
			else
				@removeBusyState()
				return alert "something went wrong. Please try again."


		@removeBusyState()
		if error and error.code then return @showError error
		else alert "something went wrong. Please try again."
	showError: (error) ->
		switch error.code
			when Parse.Error.USERNAME_TAKEN, Parse.Error.EMAIL_NOT_FOUND then alert "The password was wrong or the email/username was already taken"
			when Parse.Error.INVALID_EMAIL_ADDRESS then alert "The provided email is invalid. Please check it, and try again"
			when Parse.Error.TIMEOUT then alert "The connection timed out. Please try again."
			when Parse.Error.USERNAME_TAKEN then alert "The email/username was already taken"
			when 202 then alert "The email is already in use, please login instead"
			when 101 then alert "Wrong email or password"
			else alert "something went wrong. Please try again."

# Log into services
Parse.initialize( "0qD3LLZIOwLOPRwbwLia9GJXTEUnEsSlBCufqDvr", "TcteeVBhtJEERxRtaavJtFznsXrh84WvOlE6hMag" )

# Handle Fabebook Login
window.fbAsyncInit = ->
	Parse.FacebookUtils.init
		appId: '312199845588337'	        	                # App ID from the app dashboard
		channelUrl : 'http://test.swipesapp.com/channel.html' 	# Channel file for x-domain comms
		status: no                		                 		# Check Facebook Login status
		cookie: yes                           		      		# enable cookies to allow Parse to access the session
		xfbml: yes                                				# Look for social plugins on the page

# Load Fabebook JS SDK
do ->
	if document.getElementById 'facebook-jssdk' then return

	firstScriptElement = document.getElementsByTagName( 'script' )[0]
	facebookJS = document.createElement 'script'

	facebookJS.id = 'facebook-jssdk'
	facebookJS.src = '//connect.facebook.net/en_US/all.js'

	firstScriptElement.parentNode.insertBefore( facebookJS, firstScriptElement )

# Finally, instantiate a new SwipesLogin
login = new LoginView()