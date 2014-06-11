define ["underscore", "js/model/TagModel"], (_, TagModel) ->
	Backbone.View.extend
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
			@addTagToModel( $( e.currentTarget ).text(), no )

		removeTag: (e) ->
			tagName = $.trim $(e.currentTarget).text()
			tags = _.reject( @model.get( "tags" ), (t) -> t.get( "title" ) is tagName )

			@model.updateTags tags
		createTag: (e) ->
			e.preventDefault()
			tagName = @$el.find("form.add-tag input").val()
			return if tagName is ""

			@addTagToModel tagName
		addTagToModel: (tagName, addToCollection = yes) ->
			tags = @model.get( "tags" ) or []

			if _.filter( tags, (t) -> t.get( "title" ) is tagName ).length
				return alert "You've already added that tag"

			tag = swipy.tags.findWhere { title: tagName }

			if tag?
				tags.push tag 
			else
				newTag = swipy.tags.create 
					title : tagName
				tags.push newTag

			@model.updateTags tags

			# If it's a new tag, add it to the stack. getTagsFromTasks will automatically sav new tags.
			#if addToCollection then swipy.tags.getTagsFromTasks()
		render: ->
			@renderTags()
			@renderTagPool()

			if @toggled then @$el.find("form.add-tag input").focus()

			return @el

		renderTags: ->
			list = @$el.find " > .rounded-tags"
			list.empty()

			if @model.has "tags"
				tags = _.invoke( @model.get( "tags" ), "get", "title" )
				tags = _.sortBy( tags, (tag) -> tag.toLowerCase() )
				@renderTag( tag, list, "selected" ) for tag in tags

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
			if @model.has "tags"
				unusedTags = _.without( allTags, _.invoke( @model.get("tags"), "get", "title" )... )
			else
				unusedTags = allTags

			@renderTag( tagname, list ) for tagname in _.sortBy( unusedTags, (tag) -> tag.toLowerCase() )

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