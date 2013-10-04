define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		events: 
			"click li": "toggleFilter"
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
		render: ->
			list = @$el. find ".rounded-tags"
			list.empty()
			
			@renderTag tag, list for tag in swipy.tags.models
			@renderTagInput list

			return @el
		renderTag: (tag, list) ->
			list.append "<li>#{ tag.get 'title' }</li>" 
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


