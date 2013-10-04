define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		events: 
			"click li": "toggleFilter"
			"click .remove": "removeTag"
			"submit form": "createTag"
		initialize: ->
			@listenTo( swipy.tags, "add remove reset", @render, @ )
			@render()
		toggleFilter: (e) ->
			tag = e.currentTarget.innerText
			el = $( e.currentTarget ).toggleClass "selected"

			if el.hasClass "selected"
				Backbone.trigger( "apply-filter", "tag", tag )
			else
				Backbone.trigger( "remove-filter", "tag", tag )
		createTag: (e) ->
			e.preventDefault()
			tagName = @$el.find("form.add-tag input").val()
			return if tagName is ""

			@addTagToModel tagName
		addTagToModel: (tagName, addToCollection = yes) ->
			if _.contains( swipy.tags.pluck( "title" ), tagName )
				return alert "That tag already exists"
			else
				swipy.tags.add { title: tagName }
		removeTag: (e) ->
			e.stopPropagation()
			tagName = $.trim e.currentTarget.parentNode.innerText
			tag = swipy.tags.findWhere {title: tagName}

			if tag and confirm( "Are you sure you want to permenently delete this tag?" ) then tag.destroy
				success: (model, response) ->
					swipy.todos.remove model
				error: (model, response) ->
					alert "Something went wrong trying to delete the tag '#{ model.get 'title' }' please try again."
					console.warn "Error deleting tag — Response: ", response


		render: ->
			list = @$el. find ".rounded-tags"
			list.empty()
			
			@renderTag tag, list for tag in swipy.tags.models
			@renderTagInput list

			return @el
		renderTag: (tag, list) ->
			list.append "
				<li>
					<a class='remove' href='JavaScript:void(0);' title='Remove'>
						<span class='icon-cross'></span>
					</a>
					#{ tag.get 'title' }
				</li>"
		renderTagInput: (list) ->
			list.append "
				<li class='tag-input'>
					<form class='add-tag'>
						<input type='text' placeholder='Add new tag'>
					</form>
				</li>"
		remove: ->
			@stopListening()
			@undelegateEvents()
			@$el.remove()


