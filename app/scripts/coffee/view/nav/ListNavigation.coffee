define ["jquery"], ($) ->
	class ListNavigation
		constructor: ->
			@navLinks = $ ".list-nav a"
			@navLinks.on( "click", @handleClick )
			@facebookShare = $ ".done-socials a.facebook"
			@facebookShare.on( "click", @handleShare )
		handleClick: (e) =>
			e.preventDefault()
			swipy.router.navigate( e.currentTarget.hash[1...], yes )
		updateNavigation: (slug) =>
			@navLinks.each ->
				link = $ @
				isCurrLink = if link.attr( "href" )[1...] is "tasks/#{slug}" then yes else no
				link.toggleClass( "active", isCurrLink )
		handleShare: (e) =>
			FB.ui({
				method: 'share'
				href: 'http://swipesapp.com/'
			}, (response) ->
				console.log response
			)
			false
		destroy: ->