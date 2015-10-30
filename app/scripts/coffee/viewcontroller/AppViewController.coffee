define [
	"underscore"
	"gsap"
	"js/view/apps/InboxApp"
	], (_, TweenLite, InboxApp) ->
	Backbone.View.extend
		className: "app-view-controller"
		initialize: ->
		render: ->
			@$el.html ""
			$("#main").html(@$el)
			inboxApp = new InboxApp()
			@$el.html inboxApp.el
			inboxApp.render()
		
		open: (type, options) ->
			swipy.topbarVC.setMainTitleAndEnableProgress("Inbox", false )
			swipy.rightSidebarVC.hideSidemenu()
			@render()

		destroy: ->