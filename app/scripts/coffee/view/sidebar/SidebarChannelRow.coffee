###

###
define [
	"underscore"
	"text!templates/sidemenu/sidebar-channel-row.html"
	], (_, RowTmpl) ->
	Backbone.View.extend
		tagName: "li"
		className: "channel-row"
		events:
			"click .like-button" : "clickedLike"
		initialize: ->
			throw new Error("Model must be added when constructing a SidebarChannelRow") if !@model?
			@template = _.template RowTmpl, {variable: "data" }
			
			_.bindAll(@, "render")
			@bouncedRender = _.debounce(@render, 5)
			@model.on("change:unread_count_display", @bouncedRender )
		setUser: (user) ->
			@user = user
			@user.on("change:presence", @updatePresence, @)
		updatePresence: ->
			return if !@user?
			@$el.find(".status-container .status").toggleClass("online", (@user.get("presence") is "active"))
		render: ->
			@$el.toggleClass("unread", @model.get("unread_count_display") > 0)
			@$el.toggleClass("hasNotification", @model.get("unread_count_display") > 0) if @model.get("is_im")

			identifier = "sidebar-channel-" + @model.get("name")
			identifier = "sidebar-member-" + @user.get("name") if @model.get("is_im") and @user

			@$el.attr('id', identifier)

			@$el.html @template( channel: @model, user: @user )
			@updatePresence()
			return @

		remove: ->
			@user.off("change:presence", @updatePresence)
			@model.off("change:unread_count_display", @bouncedRender )
			@$el.empty()