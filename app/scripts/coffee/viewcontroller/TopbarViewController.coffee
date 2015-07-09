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
			@setSectionTitleAndProgress("Loading...", 30)
		render: ->
			@$el.html(@template({}))
			$(".top-bar-container").html(@$el)

		setMainTitle: (title) ->
			@$el.find(".title").html(title)
		# Progress is percentage number between 0 and 100
		setSectionTitleAndProgress: (title, progress) ->
			@currentProgress = parseInt(progress, 10)
			@$el.find(".section-title > span").html(title)
			@realignProgressBar()
		realignProgressBar: ->
			# Trying to make an estimate of the length of the text
			# This is technically not possible prerender and therefore this is a guess
			widthOfText = @$el.find('.section-title > span').text().length * 9

			actualWidth = widthOfText + 50
			@$el.find('.progress').parent().css("paddingRight",actualWidth+"px")
			@$el.find('.section-title').css("width",actualWidth+"px")
			shapePadding = actualWidth + 5 # Math.ceil(actualWidth*1.030)
			@$el.find('.shapeline').css("right",shapePadding+"px")
			@$el.find('.progress-header').toggleClass( "no-progress", !@showProgress)
			if @showProgress
				@$el.find('.progress-bar').css("width",@currentProgress+"%")