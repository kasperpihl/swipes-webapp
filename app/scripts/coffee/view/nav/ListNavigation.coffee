define ["jquery", "backbone"], ($, Backbone) ->
	class ListNavigation
		constructor: ->
			@navLinks = $ ".list-nav a"
			@navLinks.on( "click", @handleClick )
			Backbone.on( "navigate/view", @updateNavigation, @ )
		handleClick: (e) =>
			e.preventDefault()
			swipy.router.navigate( e.currentTarget.hash[1...], true )
		updateNavigation: (slug) =>
			@navLinks.each ->
				link = $ @
				isCurrLink = if link.attr( "href" )[1...] is "list/#{slug}" then yes else no
				link.toggleClass( "active", isCurrLink )
		
		