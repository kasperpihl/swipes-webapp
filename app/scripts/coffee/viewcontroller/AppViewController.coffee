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

			# Set the file identifier for loading files as text (manual parse)
			@reqFileDir = "text!apps/" + options.identifier + "/" 
			@urlDir = "http://localhost/" + options.identifier + "/"

			# Load manifest file
			@loadManifest().then( (manifest) =>
				@manifest = manifest
				swipy.topbarVC.setMainTitleAndEnableProgress(@manifest.title, false )
				
				return @loadIndex()
			).then(	(indexFile) =>
				@tpl = _.template indexFile, {variable: "swipes"} if indexFile

				$iframe = $("<iframe src=\"" + @urlDir + "../index.html\" class=\"app-frame-class\" frameborder=\"0\">")
				@$el.html ($iframe)
				$iframe.on("load", (e, b) =>
					doc = $iframe[0].contentWindow
					data = {
						path: @urlDir,
						body: @tpl(),
						scripts: @manifest.main_app.js,
						styles: @manifest.main_app.css
					}
					doc.postMessage(JSON.stringify(data), "http://localhost");
				)
			)
		loadManifest: ->
			dfd = new $.Deferred()
			require [@reqFileDir + "manifest.json"], (manifestString) =>
				# Parse the text manifest file as json
				manifest = JSON.parse(manifestString) 
				dfd.resolve(manifest)
			return dfd.promise()
		loadIndex: ->
			dfd = new $.Deferred()		
			require [@reqFileDir + @manifest.main_app.index], (Tmpl) =>
				dfd.resolve(Tmpl)
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