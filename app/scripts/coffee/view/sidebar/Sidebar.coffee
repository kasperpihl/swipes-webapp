define ["underscore", "backbone"], (_, Backbone) ->
	Parse.View.extend
		events:
			"click .close-sidebar": "handleAction"
			"click .log-out": "handleAction"
		initialize: ->
			_.bindAll( @, "handleAction" )
			$( ".open-sidebar" ).on( "click", @handleAction )

		handleAction: (e) ->
			trigger = $ e.currentTarget

			if trigger.hasClass "open-sidebar"
				$("body").toggleClass( "sidebar-open", yes )
			else if trigger.hasClass "close-sidebar"
				$("body").toggleClass( "sidebar-open", no )
			else if trigger.hasClass "log-out"
				e.preventDefault()
				if confirm "Are you sure you want to log out?"
					Parse.User.logOut();
					location.pathname = "/login/"

		destroy: ->
			@stopListening();
			$( ".open-sidebar" ).off( "click", @handleAction )