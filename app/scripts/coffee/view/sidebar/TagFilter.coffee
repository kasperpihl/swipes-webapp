define ["underscore", "text!templates/sidemenu/sidemenu-workspaces.html"], (_, WorkspacesTmpl) ->
	Backbone.View.extend
		events:
			"click li:not(.delete)": "handleClickTag"
			"click .delete": "toggleDeleteMode"
			"click .remove": "removeTag"
		initialize: ->
			@template = _.template WorkspacesTmpl
			@render = _.throttle( @render, 500 )

			@listenTo( swipy.collections.tags, "add remove reset", @render )
			@listenTo( Backbone, "apply-filter remove-filter", @handleFilterChange )
			@listenTo( Backbone, "open/viewcontroller", => _.defer => @render() )
			@listenTo( swipy.collections.todos, "change:tags", @render )
			@listenTo( Backbone, "opened-window", @clearForOpening )
			@render()
		keyDownHandling: (e) ->
			if e.metaKey or e.ctrlKey
				$('.sidebar').addClass("cmd-down")
		keyUpHandling: (e) ->
			if !e.metaKey and !e.ctrlKey
				$('.sidebar').removeClass("cmd-down")
			if e.keyCode is 27
				swipy.sidebar.popView()

		handleFilterChange: (type) ->
			# We defer 'till next event loop, because we need to make sure
			# FilterController has done its thing first.
			_.defer =>
				if type is "tag" or type is "hide-tag" or type is "all" then @render()
		handleClickTag: (e) ->
			e.preventDefault()
			if @deleteMode
				@removeTag e
			else
				@toggleFilter e
			false
		toggleDeleteMode: (e) ->
			e.stopPropagation()
			if @deleteMode then @deleteMode = off else @deleteMode = on
			@$el.toggleClass( "delete-mode", @deleteMode )
		toggleFilter: (e) ->
			tag = $.trim $( e.currentTarget ).text()
			el = $( e.currentTarget )

			unless el.hasClass "selected"
				command = "tag"
				command = "hide-tag" if e.metaKey or e.ctrlKey
				Backbone.trigger( "apply-filter", command, tag )
			else
				Backbone.trigger( "remove-filter", "tag", tag )
		removeTag: (e) ->
			e.stopPropagation()
			tagName = $.trim $( e.currentTarget ).text()
			tag = swipy.collections.tags.findWhere { title: tagName }


			wasSelected = $(e.currentTarget).hasClass "selected"

			if tag and confirm( "Are you sure you want to permenently delete this tag?" )
				tag.deleteObj()
				if wasSelected then Backbone.trigger( "remove-filter", "tag", tagName )
		getTagsForCurrentTasks: ->
			tags = []

			activeList = swipy.collections.todos.getActiveList()
			switch activeList
				when "todo" then models = swipy.collections.todos.getActive()
				when "scheduled" then models = swipy.collections.todos.getScheduled()
				else models = swipy.collections.todos.getCompleted()

			for model in models when model.has "tags"
				tags.push tagName for tagName in model.getTagStrList()

			return _.unique tags
		getValidatedTags: ->
			return swipy.collections.tags.pluck "title"

			if swipy.filter? and swipy.filter.tagsFilter.length
				swipy.collections.tags.getSiblings( swipy.filter.tagsFilter, no )
			else
				@getTagsForCurrentTasks()
		render: ->
			@$el.html @template {}
			list = @$el.find ".rounded-tags"
			list.empty()

			# Sort alphabetically, case-insensitive
			tags = @getValidatedTags()
			tags = _.sortBy( tags, (tag) -> return tag.toLowerCase() )

			@renderTag( tag, list ) for tag in tags
			if tags.length then @renderDeleteButton list

			if @deleteMode
				@$el.toggleClass( "delete-mode", on )

			return @
		renderTag: (tagName, list) ->
			if swipy.filter? and _.contains( swipy.filter.tagsFilter, tagName )
				list.append "<li class='selected'>#{ tagName }</li>"
			else if swipy.filter? and _.contains( swipy.filter.hideTagsFilter, tagName )
				list.append "<li class='selected hideTag'>#{ tagName }</li>"
			else
				list.append "<li>#{ tagName }</li>"
		clearForOpening: ->
			$('.sidebar').removeClass("cmd-down")
			#@clearLongPress()
		renderDeleteButton: (list) ->
			list.append "<li class='delete'><a href='JavaScript:void(0);' title='Delete tags'><span class='icon-trashcan'></span></a></li>"
		destroy: ->
			@stopListening()
			@undelegateEvents()


