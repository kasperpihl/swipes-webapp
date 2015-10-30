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
			script = document.createElement('script')
			
			
			require ["text!apps/inbox-app.js"],(inboxApp) =>
				scriptString = "<script type='text/javascript'>" + inboxApp + "</script>"
				@$el.append(scriptString)
		open: (type, options) ->
			swipy.topbarVC.setMainTitleAndEnableProgress("Inbox", false )
			swipy.rightSidebarVC.hideSidemenu()
			@render()

		destroy: ->