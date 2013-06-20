define ['backbone'], (Backbone) ->
	Backbone.View.extend
		events: 
			'tap .page-link': 'gotoPage'
			'click .page-link': 'gotoPage'
		initialize: ->
			_.bindAll(@)
			@timers = []
			@init()
			@render()
		init: -> 
			# In views extending me, place initialize logic here
		gotoPage: (e) ->
			link = $(e.currentTarget).attr('data-href')
			window.location.hash = link
		render: -> 
			return @el;
		customCleanUp: ->
			# Exten this in other views
		cleanUp: ->
			@customCleanUp()
			this.undelegateEvents();
			clearTimeout timer for timer in @timers