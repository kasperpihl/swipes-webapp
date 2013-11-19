define ["underscore", "backbone"], (_, Backbone) ->
	Parse.View.extend
		events:
			"click .add-new-tag": "toggleTagPool"
			"submit .add-tag": "createTag"
			"click .tag-pool li:not(.tag-input)": "addTag"
			"click .applied-tags > li": "removeTag"

		initialize: ->
			@toggled = no
			@model.on( "change:tags", @render, @ )
			@render()

		toggleTagPool: ->
			if @toggled then @hideTagPool() else @showTagPool()

		showTagPool: ->
			@toggleButton off
			@$el.addClass "show-pool"
			@$el.find("form.add-tag input").focus()
			@toggled = yes

		hideTagPool: ->
			@toggleButton on
			@$el.removeClass "show-pool"
			@$el.find("form.add-tag input").blur()
			@toggled = no

		toggleButton: (flag) ->
			icon = @$el.find ".add-new-tag span"
			icon.removeClass "icon-plus icon-minus"
			icon.addClass( if flag is on then "icon-plus" else "icon-minus" )

		addTag: (e) ->
			@addTagToModel $( e.currentTarget ).text()

		removeTag: (e) ->
			tag = $.trim $( e.currentTarget ).text()
			tags = _.without( @model.get( "tags" ), tag )

			@model.unset( "tags", { silent: yes } )
			@model.set( "tags", tags )

		createTag: (e) ->
			e.preventDefault()
			tagName = @$el.find("form.add-tag input").val()
			return if tagName is ""

			@addTagToModel tagName

		addTagToModel: (tagName, addToCollection = yes) ->
			tags = @model.get( "tags" ) or []
			if _.contains( tags, tagName ) then return alert "You've already added that tag"

			tags.push tagName
			@model.unset( "tags", { silent: yes } )

			# This triggers re-rendering
			@model.set( "tags", tags )

			# If it's a new tag, add it to the stack
			if addToCollection then swipy.tags.getTagsFromTasks()

		render: ->
			@renderTags()
			@renderTagPool()

			if @toggled then @$el.find("form.add-tag input").focus()

			return @el

		renderTags: ->
			list = @$el.find " > .rounded-tags"
			list.empty()

			if @model.has "tags" then for tagname in @model.get "tags"
				@renderTag( tagname, list, "selected" )

			icon = "<span class='" + ( if @toggled then "icon-minus" else "icon-plus" ) + "'></span>"
			poolToggler = "
				<li class='add-new-tag'>
					<a href='JavaScript:void(0);' title='Add a new tag'>" + icon + "</a>
				</li>
			"

			list.append poolToggler

		renderTagPool: ->
			list = @$el.find(".tag-pool .rounded-tags")
			list.empty()

			allTags = swipy.tags.pluck "title"
			unusedTags = if @model.has( "tags" ) then _.without( allTags, @model.get("tags")... ) else allTags
			@renderTag( tagname, list ) for tagname in unusedTags

			tagInput = "
				<li class='tag-input'>
					<form class='add-tag'>
						<input type='text' placeholder='Add new tag'>
					</form>
				</li>
			"
			list.append tagInput

		renderTag: (tagName, parent, className = "") ->
			tag = $( "<li class='#{ className }'>#{ tagName }</li>" )
			parent.append tag

		cleanUp: ->
			@model.off( null, null, @ )
			@undelegateEvents()