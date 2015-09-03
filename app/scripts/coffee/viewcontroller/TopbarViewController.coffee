define [
	"underscore"
	"text!templates/viewcontroller/topbar-view-controller.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "top-bar-inner-container"
		initialize: ->
			@template = _.template(Tmpl)
			@render()
			@currentProgress = 0
			@showProgress = true
			@setSectionTitleAndProgress("Loading...",30)
			@listenTo( Backbone, "update/numberOfTasks", @updateTaskNumber)
		updateTaskNumber: (number) ->
			label = number + " task"
			if number isnt 1
				label += "s"
			@setSectionTitleAndProgress( label)
		render: ->
			@$el.html(@template({}))
			$(".top-bar-container").html(@$el)

		setMainTitleAndEnableProgress: (title, progress) ->
			@$el.find(".title").html(title)
			@$el.find('.progress-header').toggleClass( "no-progress", !progress)
		# Progress is percentage number between 0 and 100
		setSectionTitleAndProgress: (title, progress) ->
			@$el.find(".section-title > span").html(title)

			@currentProgress = parseInt(progress, 10)
			@$el.find('.progress-bar').css("width",@currentProgress+"%")
			
			@realignProgressBar()
		realignProgressBar: ->
			# Trying to make an estimate of the length of the text
			# This is technically not possible prerender and therefore this is a guess
			widthOfText = @$el.find('.section-title > span').text().length * 9

			actualWidth = widthOfText + 50
			@$el.find('.progress').parent().css("paddingRight",actualWidth+"px")
			@$el.find('.section-title').css("width",actualWidth+"px")
			@$el.find('.shapeline').css("right",actualWidth+"px")