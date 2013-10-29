define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		el: "#add-task"
		events:
			"submit": "triggerAddTask"
			"keyup input": "resizeText"
		initialize: ->
			@input = @$el.find "input"
		triggerAddTask: (e) ->
			e.preventDefault()
			return if @input.val() is ""

			_.bindAll( @, "resizeText" )

			Backbone.trigger( "create-task", @input.val() )
			@input.val("")
			$(window).on( "resize.taskinput", @resizeText )
		getFontSizeRange: ->
			if window.innerHeight < 768
				{ min: 20, max: 40, charLimit: 20, minChars: 8 }
			else if window.innerHeight < 1024
				{ min: 35, max: 70, charLimit: 24, minChars: 15 }
			else
				{ min: 35, max: 100, charLimit: 20, minChars: 15 }
		getFontSize: ->
			numChars = @input.val().length
			range = @getFontSizeRange()

			# Only aply font-size if we have a certain amount of text
			if numChars < range.minChars then return ""

			shrinkage = ( numChars - range.minChars ) / range.charLimit
			diff = range.max - range.min

			return Math.max( range.max - ( diff * shrinkage ), range.min )
		resizeText: ->
			@input.css( "font-size", @getFontSize() )
		remove: ->
			@undelegateEvents();
			@$el.remove()
			$(window).off( "resize.taskinput" )