define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		initialize: ->
			@timers = []
			@init()
			@render()
		init: -> 
			# In views extending me, place initialize logic here
		render: -> 
			return @el;
		customCleanUp: ->
			# Extend this in other views
		remove: ->
			@customCleanUp()
			this.undelegateEvents();
			clearTimeout timer for timer in @timers