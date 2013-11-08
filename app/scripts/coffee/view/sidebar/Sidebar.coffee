define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
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
				console.log "Log out"

		destroy: ->
			@stopListening();
			$( ".open-sidebar" ).off( "click", @handleAction )