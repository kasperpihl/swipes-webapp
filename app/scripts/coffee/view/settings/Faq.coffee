define ["view/settings/BaseSubview", "gsap", "text!templates/settings-faq.html"], (BaseView, TweenLite, Tmpl) ->
	BaseView.extend
		className: "faq"
		events:
			"click header": "toggleQuestion"
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			BaseView::render.apply( @, arguments )

			@$el.find( "li section" ).each ->
				TweenLite.set( $(@), { rotationX: -90, marginBottom: 0, display: "none" } )
		toggleQuestion: (e) ->
			li = $(e.currentTarget.parentNode).toggleClass "toggled"

			if li.hasClass "toggled"
				TweenLite.to( li.find( "section" ), 0.55, { alpha: 1, height: "auto", marginBottom: "3.2em", rotationX: 0, display: "block", ease: Back.easeOut } );
			else
				TweenLite.to( li.find( "section" ), 0.2, { alpha: 0, height: 0, marginBottom: 0, rotationX: -90, display: "none" } );