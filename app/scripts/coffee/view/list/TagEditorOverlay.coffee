define ["underscore", "backbone", "view/Overlay", "model/TagModel", "text!templates/tags-editor-overlay.html"], (_, Backbone, Overlay, TagModel, TagsEditorOverlayTmpl) ->
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

			# Convert tag lists from a list of models to a list of strings
			stringLists = []
			for modelList in tagLists
				stringLists.push _.invoke( modelList, "get", "title" )

			# Then, go over each task and find out if there are any tags shared by all of them
			return _.intersection stringLists...
		getTagFromName: (tagName) ->
			# First see if tag exists
			tag = swipy.tags.findWhere { title: tagName }
			if tag then return tag
		render: () ->
			@$el.html @template( { allTags: swipy.tags.toJSON(), tagsAppliedToAll: @getTagsAppliedToAll() } )
			console.log "Rendering tag overlay"
			if not $("body").find(".overlay.tags-editor").length
				$("body").append @$el

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
				tag = @getTagFromName tagName
				if not tag and addToCollection then tag = new TagModel { title: tagName }

				if addToCollection
					swipy.tags.add tag
					tag.save().then =>
						@addTagToModel( tag, model ) for model in @options.models
				else
					@addTagToModel( tag, model ) for model in @options.models

				@render()
		modelHasTag: (model, tag) ->
			tagName = tag.get "title"
			return !!_.filter( model.get( "tag" ), (t) -> t.get( "title" ) is tagName ).length
		addTagToModel: (tag, model) ->
			if model.has "tags"
				if @modelHasTag( model, tag ) then return
				tags = model.get "tags"
				tags.push tag
				model.unset( "tags", { silent: yes } )
				model.save( "tags", tags )
			else
				model.save( "tags", [tag] )
		removeTagFromModels: (tag) ->
			for model in @options.models
				tags = model.get "tags"
				newTags = _.without( tags, tag )
				model.unset( "tags", { silent: yes } )
				model.save( "tags", newTags )

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

