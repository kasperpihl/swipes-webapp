define ["underscore", "backbone", "view/Overlay", "text!templates/tags-editor-overlay.html"], (_, Backbone, Overlay, TagsEditorOverlayTmpl) ->
	Overlay.extend
		className: 'overlay tags-editor'
		events:
			"click .overlay-bg": "destroy"
			"click .save": "destroy"
			"click .rounded-tags li:not(.tag-input)": "toggleTag"
			"submit form": "createTag"
		initialize: ->
			Overlay::initialize.apply( @, arguments )
			@showClassName = "tags-editor-open"
			@hideClassName = "hide-tags-editor"
			@render()
		bindEvents: ->
			_.bindAll( @, "handleResize" )
			$(window).on( "resize", @handleResize )
		setTemplate: ->
			@template = _.template TagsEditorOverlayTmpl
		getTagsAppliedToAll: ->
			# First check that all currently selected tasks have tags applied
			tagLists = _.invoke( @options.models, "get", "tags" )
			return [] if _.contains( tagLists, null )

			# Then, go over each task and find out if there are any tags shared by all of them
			_.intersection tagLists...
		render: () ->
			@$el.html @template( { allTags: swipy.tags.toJSON(), tagsAppliedToAll: @getTagsAppliedToAll() } )

			if not @addedToDom
				$("body").append @$el
				@addedToDom = yes

			@show()
			@handleResize()
			@$el.find( ".tag-input input" ).focus()
			return @
		afterHide: ->
			Backbone.trigger "redraw-sortable-list"
		toggleTag: (e) ->
			target = $ e.currentTarget
			remove = target.hasClass "selected"
			tag = target.text()

			console.log "Toggle #{tag} ", !remove

			if remove then @removeTagFromModels tag
			else @addTagToModels( tag, no )
		createTag: (e) ->
			e.preventDefault()
			tagName = @$el.find("form.add-tag input").val()
			return if tagName is ""

			@addTagToModels tagName
		addTagToModels: (tagName, addToCollection = yes) ->
			if addToCollection and _.contains( swipy.tags.pluck( "title" ), tagName )
				return alert "That tag already exists"
			else
				@addTagToModel( tagName, model ) for model in @options.models
				if addToCollection then swipy.tags.getTagsFromTasks()
				@render()
		addTagToModel: (tagName, model) ->
			if model.has "tags"
				tags = model.get "tags"
				if _.contains( tags, tagName ) then return
				tags.push tagName
				model.unset( "tags", { silent: yes } )
				model.set( "tags", tags )
			else
				return model.set( "tags", [tagName] )
		removeTagFromModels: (tag) ->
			for model in @options.models
				tags = model.get "tags"
				newTags = _.without( tags, tag )
				model.unset( "tags", { silent: yes } )
				model.set( "tags", newTags )

			@render()
		handleResize: ->
			return unless @shown

			content = @$el.find ".overlay-content"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin-top", offset )
		cleanUp: ->
			$(window).off("resize", @handleResize)

			# Same as super() in real OOP programming
			Overlay::cleanUp.apply( @, arguments )

