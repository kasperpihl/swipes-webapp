define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		events: 
			"click li": "toggleFilter"
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


