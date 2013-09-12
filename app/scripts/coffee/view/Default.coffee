define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		initialize: ->
			#_.bindAll @
			@timers = []
			@init()
			@render()
		init: -> 
			# In views extending me, place initialize logic here
		render: -> 
			return @el;
		customCleanUp: ->
			# Extend this in other views
		cleanUp: ->
			@customCleanUp()
			this.undelegateEvents();
			clearTimeout timer for timer in @timers