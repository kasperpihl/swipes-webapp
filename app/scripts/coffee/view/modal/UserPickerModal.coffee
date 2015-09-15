define ["underscore",
		"js/view/modal/ModalView"
		"text!templates/modal/user-picker-modal.html"
		"text!templates/modal/user-picker-row.html"], (_, ModalView, Tmpl, RowTmpl) ->
	ModalView.extend
		className: 'user-picker-modal'
		initialize: ->
			@setTemplates()
			@bouncedRender = _.debounce(@render, 5)
			_.bindAll(@, "clickedPerson", "render", "bouncedRender")
			@searchField = false
			@title = "Select people"
			@emptyMessage = "No people found"
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
		loadPeople: ->
			@people = @dataSource.userPickerModalPeople(@)
			@filteredPeople = @people
		search: (e) ->
			if e.keyCode is 27
				@$el.find("input").blur()
				return
			searchString = @$el.find("input").val()
			if !searchString? or !searchString.length
				@filteredPeople = @people
				@renderPeople()
				return
			searchString = searchString.toLowerCase()
			newFilter = []
			for person in @people
				if person.name.toLowerCase().startsWith(searchString)
					newFilter.push(person)
					continue
				if person.profile.first_name? and person.profile.first_name.toLowerCase().startsWith(searchString)
					newFilter.push(person)
					continue
				if person.profile.last_name? and person.profile.last_name.toLowerCase().startsWith(searchString)
					newFilter.push(person)
					continue
			@filteredPeople = newFilter
			@renderPeople()
		render: ->
			throw new Error("AssignModal must have dataSource") if !@dataSource?
			throw new Error("AssignModal dataSource must implement userPickerModalPeople") if !_.isFunction(@dataSource.userPickerModalPeople)
			
			html = @template({ searchField: @searchField, title: @title})
			@$el.html html
			@renderPeople()
			return @
		didPresentModal: ->
			@$el.find("input").focus()
		renderPeople: ->
			@$el.find(".user-picker-list-container").html @rowTemplate({people: @filteredPeople, emptyMessage: @emptyMessage })
			@$el.find(".user-picker-list-container .user").on("click", @clickedPerson)
		clickedPerson: (e) ->
			$el = $(e.currentTarget)
			userId = $el.attr("data-href")
			targetUser = swipy.slackCollections.users.get(userId)
			if @delegate? and _.isFunction(@delegate.userPickerClickedUser)
				val = @delegate.userPickerClickedUser(targetUser)
			if @selectOne
				@dismissModal()
			else
				i = 0
				for person in @people
					if person? and person.id is userId
						@people.splice(i, 1)
						break
					i++
				@removePerson(userId)
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