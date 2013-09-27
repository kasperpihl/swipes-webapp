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
		cleanUp: ->
			# Extend this in other views
		remove: ->
			@cleanUp()
			this.undelegateEvents();
			clearTimeout timer for timer in @timers