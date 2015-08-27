define ["underscore"], (_) ->
	Backbone.Model.extend
		className: "User"
		capitalizedName: ->
			@get("name").charAt(0).toUpperCase() + @get("name").slice(1)