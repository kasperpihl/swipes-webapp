define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		events:
			"click li": "toggleFilter"
			"click .remove": "removeTag"
			"submit form": "createTag"
		initialize: ->
			@listenTo( swipy.tags, "add remove reset", @render )
			@listenTo( Backbone, "apply-filter remove-filter", @handleFilterChange )
			@render()
		handleFilterChange: (type) ->
			_.defer =>
				if type is "tag" then @render()
		toggleFilter: (e) ->
			tag = $.trim $( e.currentTarget ).text()
			el = $( e.currentTarget )

			unless el.hasClass "selected"
				Backbone.trigger( "apply-filter", "tag", tag )
			else
				Backbone.trigger( "remove-filter", "tag", tag )
		createTag: (e) ->
			e.preventDefault()
			tagName = @$el.find("form.add-tag input").val()
			return if tagName is ""

			@addTag tagName
		addTag: (tagName) ->
			swipy.tags.add { title: tagName }
		removeTag: (e) ->
			e.stopPropagation()
			tagName = $.trim $( e.currentTarget.parentNode ).text()
			tag = swipy.tags.findWhere {title: tagName}

			wasSelected = $(e.currentTarget.parentNode).hasClass "selected"

			if tag and confirm( "Are you sure you want to permenently delete this tag?" ) then tag.destroy
				success: (model, response) ->
					swipy.todos.remove model
					if wasSelected then Backbone.trigger( "remove-filter", "tag", tagName )
				error: (model, response) ->
					alert "Something went wrong trying to delete the tag '#{ model.get 'title' }' please try again."
					console.warn "Error deleting tag — Response: ", response
		getValidatedTags: ->
			swipy.tags.getSiblings( swipy.filter.tagsFilter, no )
		render: ->
			list = @$el. find ".rounded-tags"
			list.empty()

			# If we have a tag filter, make sure tags validate before rendering them.
			if swipy.filter?.tagsFilter.length > 0
				@renderTag tag, list for tag in @getValidatedTags()
			else
				@renderTag tag, list for tag in swipy.tags.pluck "title"
				@renderTagInput list

			return @
		renderTag: (tag, list) ->
			if swipy.filter? and _.contains( swipy.filter.tagsFilter, tag )
				list.append "<li class='selected'>#{ tag }</li>"
			else
				list.append "<li>#{ tag }</li>"
		renderTagInput: (list) ->
			list.append "
				<li class='tag-input'>
					<form class='add-tag'>
						<input type='text' placeholder='Add new tag'>
					</form>
				</li>"
		destroy: ->
			@stopListening()
			@undelegateEvents()


