define [
	"underscore"
	"gsap"
	], (_, TweenLite) ->
	Backbone.View.extend
		className: "app-view-controller"
		initialize: ->
		render: ->

		open: (type, options) ->
			swipy.rightSidebarVC.hideSidemenu()
			@$el.html "Loading App"
			$("#main").html(@$el)
			@appsUrl = urlbase + "/apps"
			# Set the file identifier for loading files as text (manual parse)
			@thisAppUrl = @appsUrl + "/" + options.id + "/"
			
			# Load manifest file
			@loadManifest().then( (manifest) =>
				@manifest = manifest
				swipy.topbarVC.setMainTitleAndEnableProgress(@manifest.title, false )
				
				return @loadIndex()
			).then(	(indexFile) =>
				@tpl = _.template indexFile, {variable: "swipes"} if indexFile

				$iframe = $("<iframe src=\"" + @appsUrl + "/app-loader\" class=\"app-frame-class\" frameborder=\"0\">")
				@$el.html ($iframe)
				$iframe.on("load", (e, b) =>
					doc = $iframe[0].contentWindow
					event = {
						ok:true,
						event: "app.run"
						data:{
							identifier: options.id,
							body: @tpl(),
							scripts: @manifest.main_app.js,
							styles: @manifest.main_app.css
						}
					}
					doc.postMessage(JSON.stringify(event), @appsUrl);
					$(document).mousedown(
						(e) =>
							$iframe.blur() if @isInIframe
					)
					$iframe.mouseenter(
						(e) =>
							@isInIframe = true
					)
					$iframe.mouseleave(
						(e) =>
							@isInIframe = false
							
					)
				)
				window.addEventListener("message", @receivedMessageFromApp, false);
			)
		receivedMessageFromApp: (message, test) ->
			window.receivedMessageFromApp = message
			
			data = JSON.parse(message.data)
			console.log "message from app", data
		loadManifest: ->
			dfd = new $.Deferred()
			$.get(@thisAppUrl + "manifest.json", (data) =>
				dfd.resolve(data)
			)
			return dfd.promise()
		loadIndex: ->
			dfd = new $.Deferred()
			$.get(@thisAppUrl + @manifest.main_app.index, (data) =>
				dfd.resolve(data)
			)
			return dfd.promise()
		
		destroy: ->


###
	A fake Inbox app

define [
	"underscore"
	"text!templates/apps/inbox-app.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "inbox-app-extension"
		initialize: ->
			@template = _.template Tmpl, {variable: "data" }
			@render()
		render: ->
			@$el.html @template()
			return @
###