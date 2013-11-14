define ["underscore", "backbone", "gsap"], (_, Backbone) ->

	# The clockwork of Swipes that tells the rest of the system, when it's time to move
	# tasks from scheduled to active.
	#
	# Internally, the timer uses TweenLite from GreenSock. This might seem a little strange, but
	# TweenLite, unlike a good old setTimeout, can tell you how long is left in the current timer clock
	# and it is more predictable. A setTimeout for 10 seconds is not 10 seconds in reality, but 10 seconds +
	# any script execution time during those 10 seconds — Thus making the timer unpredictable after
	# the app has been open for a longer period of time.
	#
	# Additionally, TweenLite uses requestAnimationFrame when available, which means that if the tab containing
	# the app, isn't currently active, we won't waste any background processing power to update it, but
	# as soon as the tab becomes active, we pick up in the right place.
	class ClockWork
		constructor: ->
			@timesUpdated = 0
			@timer = @getTimer()
		getTimer: ->
			if @timer and @timer.progress < 1
				return @timer
			else
				return TweenLite.to({a:0}, @getSecondsRemainingThisMin(), { a:1, onComplete: @tick, onCompleteScope: @, ease:Linear.easeNone } )
		tick: ->
			@timesUpdated++
			@timer = @getTimer()
			Backbone.trigger( "clockwork/update", @ )
		getSecondsRemainingThisMin: ->
			60 - new Date().getSeconds()
		timeToNextTick: ->
			@timer.duration() - @timer.time()
		destroy: ->
			@timer.kill()