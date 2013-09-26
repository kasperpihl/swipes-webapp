define ["underscore", "backbone", "text!templates/edit-task.html"], (_, Backbone, TaskTmpl) ->
	Backbone.View.extend
		events: 
			"click .add-new-tag": "toggleTagPool"
			"click .tag-pool li:not(.tag-input)": "addTag"
			"submit .add-tag": "createTag"
		initialize: ->
			@toggled = no
			@model.on( "change:tags", @render, @ )
			@render()
		toggleTagPool: ->
			if @toggled then @hideTagPool() else @showTagPool()
		showTagPool: ->
			@toggleButton off
			@$el.find(".tag-pool").addClass "show"
			@$el.find("form.add-tag input").focus()
			@toggled = yes
		hideTagPool: ->
			@toggleButton on
			@$el.find(".tag-pool").removeClass "show"
			@$el.find("form.add-tag input").blur()
			@toggled = no
		toggleButton: (flag) ->
			icon = @$el.find ".add-new-tag span"
			icon.removeClass "icon-plus icon-minus"
			icon.addClass( if flag is on then "icon-plus" else "icon-minus" )
		addTag: (e) ->
			console.log "Add tag: ", e
		createTag: (e) ->
			e.preventDefault()
			tagName = @$el.find("form.add-tag input").val()
			return if tagName is ""

			tags = @model.get( "tags" ) or []
			if _.contains( tags, tagName )
				return alert "You've already added that tag"

			tags.push tagName

			@model.unset( "tags", { silent: yes } )

			# If it's a new tag, add it to the stack
			unless _.contains( swipy.tags.pluck( "title" ), tagName )
				swipy.tags.add { title: tagName }
			
			# This trigger re-rendering
			@model.set( "tags", tags )
		render: ->
			list = @$el.find " > .rounded-tags"
			list.empty()

			if @model.has "tags"
				for tagname in @model.get "tags"
					@renderTag( tagname, list, yes )

			icon = "<span class='" + ( if @toggled then "icon-minus" else "icon-plus" ) + "'></span>"
			poolToggler = "
				<li class='add-new-tag'>
					<a href='JavaScript:void(0);' title='Add a new tag'>" + icon + "</a>
				</li>
			"

			list.append poolToggler

			@renderTagPool()

			if @toggled
				@$el.find("form.add-tag input").focus()

			return @el
		renderTagPool: ->
			list = @$el.find(".tag-pool .rounded-tags")
			list.empty()
			
			if @model.has "tags"
				allTags = swipy.tags.pluck "title"
				unusedTags = _.without( allTags, @model.get("tags")... )

				for tagname in unusedTags
					@renderTag( tagname, list )

			tagInput = "
				<li class='tag-input'>
					<form class='add-tag'>
						<input type='text' placeholder='Add new tag'>
					</form>
				</li>
			"
			list.append tagInput
		renderTag: (tagName, parent, removable = no) ->
			tag = document.createElement "li"
			tag.innerText = tagName
			parent.append tag

			if removable
				removeBtn = "
					<a class='remove' href='JavaScript:void(0);' title='Remove'>
						<span class='icon-cross'></span>
					</a>
				"
				$(tag).prepend removeBtn
		cleanUp: ->
			@model.off()
			@undelegateEvents()