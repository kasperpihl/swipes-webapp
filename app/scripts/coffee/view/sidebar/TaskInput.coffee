define ["underscore", "text!templates/sidemenu/sidemenu-add.html"], (_, AddTmpl) ->
	Backbone.View.extend
		className: "add-sidemenu"
		events:
			"submit": "triggerAddTask"
			"focus input": "focusInput"
			"blur input": "blurInput"
			"keyup input": "resizeText"
			"click .priority": "togglePriority"
		initialize: ->
			@template = _.template AddTmpl
			_.bindAll( @, "resizeText" )
			$(window).on( "resize.taskinput", @resizeText )
			@render()
		render: ->
			@$el.html @template {}
		togglePriority: (e) ->
			$('.add-new').toggleClass("is-priority")
		focusInput: (e) ->
			swipy.shortcuts.pushDelegate(@)
		blurInput: (e) ->
			swipy.shortcuts.popDelegate()
		keyUpHandling: (e) ->
			if e.keyCode is 27
				@$el.find("input").blur()
		triggerAddTask: (e) ->
			e.preventDefault()
			return if @$el.find("input").val() is ""

			Backbone.trigger( "create-task", @$el.find("input").val() )
			@$el.find("input").val ""
		getFontSizeRange: ->
			if window.innerHeight < 768 and window.innerWidth < 450
				{ min: 20, max: 40, charLimit: 20, minChars: 8 }
			else if window.innerHeight < 768
				{ min: 35, max: 70, charLimit: 20, minChars: 15 }
			else if window.innerHeight < 1024
				{ min: 35, max: 70, charLimit: 24, minChars: 15 }
			else
				{ min: 35, max: 100, charLimit: 20, minChars: 15 }
		getFontSize: ->
			numChars = @$el.find("input").val().length
			range = @getFontSizeRange()

			# Only aply font-size if we have a certain amount of text
			if numChars < range.minChars then return ""

			shrinkage = ( numChars - range.minChars ) / range.charLimit
			diff = range.max - range.min

			return Math.max( range.max - ( diff * shrinkage ), range.min )
		resizeText: ->
			@$el.find("input").css( "font-size", @getFontSize() )
		remove: ->
			@undelegateEvents()
			@$el.remove()
			$(window).off( "resize.taskinput" )