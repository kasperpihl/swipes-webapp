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
			@urlDir = "http://127.0.0.1:9000/apps/" + options.identifier + "/"
			# Load manifest file
			@loadManifest().then( (manifest) =>
				@manifest = manifest
				swipy.topbarVC.setMainTitleAndEnableProgress(@manifest.name, false )
				
				return @loadBody()
			).then(	(bodyFile) =>
				@bodyTpl = _.template bodyFile, {variable: "data"} if bodyFile
				
				return @loadHead()
			).then( (headFile) =>
				@headTpl = _.template headFile, {variable: "data"} if headFile
				
				return @loadStyles()
			).then( (styles) =>
				@styles = styles

				return @loadScripts()
			).then( (scripts) =>
				@scripts = scripts

				$iframe = $("<iframe class=\"app-frame-class\" frameborder=\"0\">")
				@$el.html ($iframe)
				setTimeout( =>
					doc = $iframe[0].contentWindow.document
					$body = $('body',doc)
					$head = $('head', doc)
					$head.html(@headTpl()) if @headTpl
					$body.html(@bodyTpl()) if @bodyTpl

					for style in @styles
						styleString = "<style>" + style + "</style>"
						$head.prepend(styleString)
					for script in @scripts
						scriptString = "<script type='text/javascript'>(function() { " + script + " })();</script>"
						$body.append(scriptString)
				, 1)
				

			)
		loadManifest: ->
			dfd = new $.Deferred()
			require [@reqFileDir + "manifest.json"], (manifestString) =>
				# Parse the text manifest file as json
				manifest = JSON.parse(manifestString) 
				dfd.resolve(manifest)
			return dfd.promise()
		loadHead: ->
			dfd = new $.Deferred()
			if !@manifest.main_app.head
				dfd.resolve()
			else
				require [@reqFileDir + @manifest.main_app.head], (Tmpl) =>
					dfd.resolve(Tmpl)
			return dfd.promise()
		loadBody: ->
			dfd = new $.Deferred()		
			require [@reqFileDir + @manifest.main_app.body], (Tmpl) =>
				dfd.resolve(Tmpl)
			return dfd.promise()
		
		loadStyles: ->
			dfd = new $.Deferred()

			styles = []
			dfd.resolve(styles) if !@manifest.main_app.css

			for file in @manifest.main_app.css
				styles.push(@reqFileDir + file)
			require styles, () =>
				dfd.resolve(arguments)

			return dfd.promise()
		loadScripts: ->
			dfd = new $.Deferred()

			scripts = []
			dfd.resolve(scripts) if !@manifest.main_app.js

			for file in @manifest.main_app.js
				scripts.push(@reqFileDir + file)
			
			require scripts, () =>
				dfd.resolve(arguments)

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