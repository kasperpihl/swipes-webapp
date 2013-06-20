require ['jquery', 'underscore', 'backbone', 'Bootstrap', 'plugins/log'], ($, _, Backbone, App) ->
	window.$ = window.jQuery = $
	window._ = _
	window.Backbone = Backbone

	new App()