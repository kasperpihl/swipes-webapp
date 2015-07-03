define ["underscore"], (_) ->
	Backbone.View.extend
		el: ".organise-bar"
		events:
			"click .start-day-button": "startDay"
			"click .back-button": "back"
		constructor: ( obj ) ->
			_.bindAll( @, "back" )
			@goal = 3
			@currentSelectedTasks = 0
			@didOverdo = false
			if obj and obj.goal
				@goal = obj.goal
			Backbone.View.apply @, arguments
		initialize: (obj)->
			@listenTo( swipy.todos, "change:selected", @toggle )
			$("body").addClass("organise")
			@toggle()
		back: ->
			@goBack(true)
			return false
		goBack: (trigger) ->
			newPath = "tasks/now"
			if Backbone.history.fragment.indexOf("/organise") isnt -1
				newPath = Backbone.history.fragment.replace("/organise","")
			swipy.router.navigate(newPath, trigger)
		success: ->
			@goBack(true)
			alert("Now you can focus on the important things, we have rescheduled the rest for tomorrow. Stay productive.")
		startDay: ->
			if @currentSelectedTasks is 0
				alert("Choose the tasks for today and then click start day")
			else
				Backbone.trigger("schedule-all-but-selected")
			return false
		toggle: ->
			selectedTasks = swipy.todos.filter (m) -> m.get "selected"
			@currentSelectedTasks = selectedTasks.length
			if @currentSelectedTasks >= @goal
				@$el.find('.start-day-section').addClass("active")
			else 
				@$el.find('.start-day-section').removeClass("active")

			$html = $('.todo-list.todo')
			
			title = "" + selectedTasks.length + " / " + @goal + " Selected"
			if selectedTasks.length >= @goal
				title = "All Selected!"
			$html.find('.app-header h1 > span').html(title)

			percentage = parseFloat(selectedTasks.length) / @goal * 100
			widthOfText = $html.find('.app-header h1 > span').text().length * 8
			actualWidth = widthOfText + 50
			$html.find('.progress').parent().css("paddingRight",actualWidth+"px")
			$html.find('h1').css("width",actualWidth+"px")
			shapePadding = actualWidth*1.025
			$html.find('.shapeline').css("right",shapePadding+"px")
			$html.find('.progress-bar').css("width",percentage+"%")
		destroy: ->
			@kill()
		kill: ->
			$('body').removeClass("organise")
			swipy.router.lastMainRoute = "tasks/now"
			@undelegateEvents()
			@stopListening()