define ["underscore", "backbone", "jquery", "gsap", "timelinelite"], (_, Backbone, $) ->
	Backbone.View.extend
		shown: no
		className: "sync-indicator"
		initialize: ->
			_.bindAll @, "checkStatus"
			@render()
			@buildAnimationTimeline()
			# setInterval @checkStatus, 500
		checkStatus: ->
			if $.active > 0 then @show() else @hide()
		buildAnimationTimeline: ->
			@tl = new TimelineLite
				paused: true
				onStart: => TweenLite.set( @el, { display: "block" } )
				onComplete: => TweenMax.fromTo( @$('.icon'), 1, { rotation: 0 }, { rotation: 360, repeat: -1, transformOrigin: "55% 43%", ease: Power1.easeInOut } )
				onReverseComplete: => TweenLite.set( @el, { display: "none" } )

			@tl.fromTo( @$('.icon'), 0.3, { scale: 0, opacity: 0 }, { scale: 1, opacity: 1 } )
			@tl.fromTo( @$('.sync-text'), 0.2, { opacity: 0 }, { opacity: 1 } )
		show: ->
			return unless not @shown
			$("body").addClass "syncing"

			@tl.play()

			@shown = yes
		hide: ->
			return unless @shown
			$("body").removeClass "syncing"

			TweenMax.from( @$('.icon'), 0.5, { rotation: 360, overwrite: "all" } )
			@tl.reverse()

			@shown = no
		getHTML: ->
			"""
				<div class='icon-wrap'>
					<div class="icon icon-repeat"></div>
				</div>
				<p class='sync-text'>Syncing</p>
			"""
		render: ->
			@$el.html @getHTML();
			TweenLite.set( @el, { display: "none" } )