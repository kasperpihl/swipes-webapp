define ->
	class ViewController
		constructor: (opts) ->
			@init()
			@navLinks = $('.list-nav a')
		init: ->
			# Listen for navigation events
			$(document).on( 'navigate/page', (e, slug) => @goto slug )
		goto: (slug) ->
			@updateNavigation slug
			@transitionViews slug
		updateNavigation: (slug) =>
			@navLinks.each ->
				link = $(@)
				isCurrLink = if link.attr("href")[1...] is slug then yes else no
				link.toggleClass( 'active', isCurrLink )
		transitionViews: (newViewSlug) ->
			console.log "Tranisiton between views to #{newViewSlug}"