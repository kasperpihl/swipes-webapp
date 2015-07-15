define [
	"underscore"
	], (_) ->
	Backbone.View.extend
		el: ".right-sidebar-content"
		initialize: ->
			@setTemplates()
			@renderSidebar()
			_.bindAll( @, "renderSidebar")
			@listenTo( Backbone, "set-active-menu", @setActiveMenu )
		setTemplates: ->
			
		renderSidebar: ->
			
		setActiveMenu: (activeClass) ->
			$(".sidebar-controls .active").removeClass("active")
			$(".sidebar-controls #"+activeClass).addClass("active")