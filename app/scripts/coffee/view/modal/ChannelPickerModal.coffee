define ["underscore",
		"js/view/modal/ModalView"
		"text!templates/modal/picker-modal.html"
		"text!templates/modal/channel-picker-row.html"], (_, ModalView, Tmpl, RowTmpl) ->
	ModalView.extend
		className: 'picker-modal'
		initialize: ->
			@setTemplates()
			@bouncedRender = _.debounce(@render, 5)
			_.bindAll(@, "clickedRow", "render", "bouncedRender")
			@searchField = false
			@title = "Select channel"
			@emptyMessage = "No channel found"
			@selectOne = true
		events:
			"blur input": "test"
			"keyup input": "search"
			"change input": "search"
		test: (e) ->
			true
		setTemplates: ->
			@template = _.template Tmpl, {variable: "data"}
			@rowTemplate = _.template RowTmpl, {variable: "data"}
		loadChannels: ->
			@channels = @dataSource.channelPickerModalChannels(@)
			@filteredChannels = @channels
		search: (e) ->
			if e.keyCode is 27
				@$el.find("input").blur()
				return
			searchString = @$el.find("input").val()
			if !searchString? or !searchString.length
				@filteredChannels = @channels
				@renderChannels()
				return
			searchString = searchString.toLowerCase()
			newFilter = []
			for channel in @channels
				if channel.name.toLowerCase().startsWith(searchString)
					newFilter.push(channel)
					continue
			@filteredChannels = newFilter
			@renderChannels()
		render: ->
			throw new Error("ChannelPickerModal must have dataSource") if !@dataSource?
			throw new Error("ChannelPickerModal dataSource must implement channelPickerModalChannel") if !_.isFunction(@dataSource.channelPickerModalChannels)
			
			html = @template({ searchField: @searchField, title: @title})
			@$el.html html
			@renderChannels()
			return @
		didPresentModal: ->
			@$el.find("input").focus()
		renderChannels: ->
			@$el.find(".picker-list-container").html @rowTemplate({channels: @filteredChannels, emptyMessage: @emptyMessage })
			@$el.find(".picker-list-container .channel").on("click", @clickedRow)
		clickedRow: (e) ->
			$el = $(e.currentTarget)
			channelId = $el.attr("data-href")
			targetChannel = swipy.slackCollections.channels.get(channelId)
			if @delegate? and _.isFunction(@delegate.channelPickerClickedChannel)
				val = @delegate.channelPickerClickedChannel(targetChannel)
			if @selectOne
				@dismissModal()
			else
				i = 0
				for channel in @channels
					if channel? and channel.id is channelId
						@channels.splice(i, 1)
						break
					i++
				@removeChannel(channelId)
		removePerson: (href, callback) ->
			dfd = new $.Deferred()
			el = @$el.find('li[data-href='+href+']')
			el.addClass('animated-short')
			el.addClass('fadeOut')
			setTimeout(->
				el.remove()
				dfd.resolve()
			, 300)
			return dfd.promise()